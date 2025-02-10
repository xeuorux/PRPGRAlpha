class Hash
    def add(key, value)
        self[key] = value
    end
end

class PokeBattle_AI_Boss
    DEFAULT_BOSS_AGGRESSION = 2
    MAX_BOSS_AGGRESSION = 8

    def useUniversalBehaviours?; return true; end

    def initialize(_user, _battle)
        # Always or never use a move (if possible)
        # Arrays of moves
        @requiredMoves = []
        @rejectedMoves = []

        # Determining if a move should be used based on unique conditions
        # Arrays of condition procs, that can evaluate multiple moves
        @useMovesIFF = []
        @rejectMovesIf = []
        @requireMovesIf = []

        # Determining if a move should be used based on unique conditions
        # Hashes, where the key is a move ID and the value is a condition proc
        # which evaluates when to use that move
        @useMoveIFF = {}
        @rejectMoveIf = {}
        @requireMoveIf = {}

        # Basic restriction on move use by round timing
        # Arrays of move ids
        @firstTurnOnly = []
        @lastTurnOnly = []
        @nonFirstTurnOnly = []
        @fallback = []

        # What happens when the move is actually decided upon
        # A hash, where the key is move ID and the value is the proc to call
        # after that move is decided upon
        @decidedOnMove = {}

        # An array of moves that, when chosen, prevent any other moves from being used this turn
        # Also implicitly means that they can only be chosen on the first turn of a round
        @wholeRound = []

        # An array of moves that, when chosen, the aggro cursor used is the bigger more scary one
        @dangerMoves = []

        # Moves that have an IFF proc condition, and also show a telegraphing warning
        # to the player when the AI decides to use them
        # A hash, where the key is a move ID and the value is a hash describing this set of special behaviour
        # The inner hash must have a :condition entry whose value is a proc which is called to determine
        # when the move should be used
        # The inner hash must also have a :warning entry whose value is a proc which must return the string
        # of the warning that is to be shown to the player
        # A move given here implicitly means it can only be chosen on the first turn of a round
        @warnedIFFMove = {}

        # An array of procs
        # All of the procs are called when the turn starts
        @beginTurn = []

        # An array of procs
        # All of the procs are called at the beginning of the first round
        @beginBattle = []

        # An array of procs
        # All of the procs are called before the Avatar performs a phase change
        @beforePhaseChange = []

        # An array of procs
        # All of the procs are called when the Avatar is destroyed
        @onDestroyed = []

        # A hash, where the key is a move ID and the value is a proc which provides a score for the given move
        @scoreMove = {}

        # Arrays of condition procs, that can evaluate multiple moves
        @scoreMoves = {}

        setUniversalBehaviours if useUniversalBehaviours?
    end

    def self.from_boss_battler(battler)
        validate battler => PokeBattle_Battler
        avatarData = GameData::Avatar.get_from_pokemon(battler.pokemon)
        if avatarData.version > 0
            id = "#{avatarData.species.to_s}_#{avatarData.version}"
        else
            id = avatarData.species.to_s
        end
        className = "PokeBattle_AI_#{id}"
        return Object.const_get(className).new(battler, battler.battle) if Object.const_defined?(className)
        echoln("[BOSS AI] Unable to find AI class for avatar with id #{id}")
        return PokeBattle_AI_Boss.new(battler, battler.battle)
    end

    def startBattle(user, battle)
        @beginBattle.each do |beginBattleProc|
            beginBattleProc.call(user, battle)
        end
    end

    def startTurn(user, battle, turnCount)
        @beginTurn.each do |beginTurnProc|
            beginTurnProc.call(user, battle, turnCount)
        end
    end

    def startPhaseChange(user, battle)
        @beforePhaseChange.each do |beforePhaseChangeProc|
            beforePhaseChangeProc.call(user, battle)
        end
    end

    def onDestroyed(user, battle)
        @onDestroyed.each do |onDestroyedProc|
            onDestroyedProc.call(user, battle)
        end
    end

    def scoreMove(move, user, target, battle)
        if @scoreMove.key?(move.id)
            moveScoreProc = @scoreMove[move.id]
            return moveScoreProc.call(move, user, target, battle)
        else
            @scoreMoves.each do |moveScoreProc|
                score = moveScoreProc.call(move, user, target, battle)
                next if score.nil?
                return score
            end
        end
        return 0
    end

    def rejectMoveForTiming?(move, user, _battle)
        if user.firstTurnThisRound?
            return true if @nonFirstTurnOnly.include?(move.id)
        else
            return true if @firstTurnOnly.include?(move.id)
            return true if @warnedIFFMove.has_key?(move.id)
        end
        return true if !user.lastTurnThisRound? && @lastTurnOnly.include?(move.id)

        return false
    end

    def requireMove?(move, user, target, battle)
        return true if @requiredMoves.include?(move.id)

        return true if @requireMoveIf.has_key?(move.id) && @requireMoveIf[move.id].call(move, user, target, battle)

        @requireMovesIf.each do |requireProc|
            return true if requireProc.call(move, user, target, battle)
        end

        return true if evaluateComboConditions(move, user, target, battle) > 0

        return false
    end

    def rejectMove?(move, user, target, battle)
        return true if rejectMoveForTiming?(move, user, battle)
        return true if @rejectedMoves.include?(move.id)

        return true if @rejectMoveIf.has_key?(move.id) && @rejectMoveIf[move.id].call(move, user, target, battle)

        @rejectMovesIf.each do |rejectProc|
            return true if rejectProc.call(move, user, target, battle)
        end

        return true if evaluateComboConditions(move, user, target, battle) < 0

        return false
    end

    # Returns 1 if required, -1 is rejected, 0 if no opinion
    def evaluateComboConditions(move, user, target, battle)
        if @warnedIFFMove.has_key?(move.id)
            return @warnedIFFMove[move.id][:condition].call(move, user, target, battle) ? 1 : -1
        end

        if @useMoveIFF.has_key?(move.id)
            return @useMoveIFF[move.id].call(move, user, target, battle) ? 1 : -1
        end

        @useMovesIFF.each do |iffCondition|
            evaluation = iffCondition.call(move, user, target, battle)
            return evaluation if evaluation && evaluation != 0
        end

        return 0
    end

    def getFallbackMove
        return @fallback.sample
    end

    def decidedOnMove(move, user, targets, battle)
        if @warnedIFFMove.has_key?(move.id)
            warningMessage = @warnedIFFMove[move.id][:warning].call(move, user, targets, battle)
            battle.pbDisplayBossNarration(warningMessage) if warningMessage
        end

        @decidedOnMove[move.id].call(move, user, targets, battle) if @decidedOnMove.has_key?(move.id)
    end

    def takesUpWholeTurn?(move, _user, _targets, _battle)
        return @wholeRound.include?(move.id)
    end

    def moveIsDangerous?(move, _user, _targets, _battle)
        return @dangerMoves.include?(move.id)
    end
end
