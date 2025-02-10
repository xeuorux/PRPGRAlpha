class PokeBattle_Battler
    #=============================================================================
    # Creating a battler
    #=============================================================================
    def initialize(btl, idxBattler, fake = false)
        @battle = btl
        @index      = idxBattler
        @captured   = false
        @dummy      = false
        @steps      = {}
        @effects    = {}
        @fake       = fake
        @damageState = PokeBattle_DamageState.new
        pbInitBlank
        pbInitProcs
        pbInitEffects(false) unless fake
    end

    def pbInitProcs
        @location = :Battler
        @apply_proc = proc do |effectData|
            effectData.apply_battler(@battle, self)
        end
        @disable_proc = proc do |effectData|
            effectData.disable_battler(@battle, self)
        end
        @eor_proc = proc do |effectData|
            effectData.eor_battler(@battle, self)
        end
        @remain_proc = proc do |effectData|
            effectData.remain_battler(@battle, self)
        end
        @expire_proc = proc do |effectData|
            effectData.expire_battler(@battle, self)
        end
        @increment_proc = proc do |effectData, increment|
            effectData.increment_battler(@battle, self, increment)
        end
    end

    def pbInitBlank
        @name           = ""
        @species        = 0
        @form           = 0
        @level          = 0
        @hp = @totalhp  = 0
        @type1 = @type2 = nil
        @ability_ids     = []
        @addedAbilities  = []
        @addedItems  = []
        @gender         = 0
        @attack = @defense = @spatk = @spdef = @speed = 0
        @status         = :NONE
        @statusCount    = 0
        @pokemon        = nil
        @pokemonIndex   = -1
        @participants   = []
        @moves          = []

        # Boss stuff
        @boss	= false
        @bossStatus	= :NONE
        @bossStatusCount = 0
        @empowered	= false
        @empoweredTimer	= 0
        @extraMovesPerTurn	= 0
        @indicesTargetedRoundBeforeLast = []
        @indicesTargetedLastRound	= []
        @indicesTargetedThisRound	= []
        @dmgMult = 1
        @dmgResist = 0
        @bossAI = nil
    end

    # Used by Future Sight only, when Future Sight's user is no longer in battle.
    def pbInitDummyPokemon(pkmn, idxParty, ability = false)
        raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
        @name         = pkmn.name
        @species      = pkmn.species
        @form         = pkmn.form
        @level        = pkmn.level
        @totalhp      = pkmn.totalhp
        @hp           = pkmn.hp
        @type1        = pkmn.type1
        @type2        = pkmn.type2
        @gender       = pkmn.gender
        @attack       = pkmn.attack
        @defense      = pkmn.defense
        @spatk        = pkmn.spatk
        @spdef        = pkmn.spdef
        @speed        = pkmn.speed
        @status       = pkmn.status
        @statusCount  = pkmn.statusCount
        @boss = pkmn.boss
        @pokemon      = pkmn
        resetAbilities(true) if ability
        @pokemonIndex = idxParty
        @participants = []
        # moves intentionally not copied across here
        @dummy = true
        @dmgMult   = 1
        @dmgResist = 0
    end

    def dummy?
        return @dummy
    end

    def pbInitPokemon(pkmn, idxParty)
        raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
        @name         = pkmn.name
        @species      = pkmn.species
        @form         = pkmn.form
        @level        = pkmn.level
        @totalhp      = pkmn.totalhp
        @hp           = pkmn.hp
        @type1        = pkmn.type1
        @type2        = pkmn.type2
        @gender       = pkmn.gender
        @attack       = pkmn.attack
        @defense      = pkmn.defense
        @spatk        = pkmn.spatk
        @spdef        = pkmn.spdef
        @speed        = pkmn.speed
        @status       = pkmn.status
        @statusCount  = pkmn.statusCount
        @dmgMult      = pkmn.dmgMult
        @dmgResist    = pkmn.dmgResist
        @boss         = pkmn.boss
        @pokemon      = pkmn
        resetAbilities(true)
        @pokemonIndex = idxParty
        @participants = [] # Participants earn Exp. if this battler is defeated
        resetMoves
        @bossAI = PokeBattle_AI_Boss.from_boss_battler(self) if @pokemon.boss?
    end

    def resetMoves
        @moves        = []
        @pokemon.moves.each_with_index do |m, i|
            @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, m)
        end
    end

    def pbInitialize(pkmn, idxParty, batonPass = false)
        deepTeeth = hasActiveAbility?(:DEEPTEETH,true)
        pbInitPokemon(pkmn, idxParty)
        pbInitEffects(batonPass, deepTeeth)
        @damageState.reset
    end

    def pbInitializeFake(pkmn, idxParty)
        pbInitPokemon(pkmn, idxParty)
        initializeEffects
        resetStatSteps
        resetTrackers
        @damageState.reset
    end

    def pbInitEffects(batonPass = false, deepTeeth = false)
        # Dragon ride ends
        if effectActive?(:GivingDragonRideTo)
            getBattlerPointsTo(:GivingDragonRideTo).disableEffect(:OnDragonRide)
        end
        
        initializeEffects(batonPass)

        # All effects stop pointing at this battler index if appropriate
        @battle.allEffectHolders do |holder|
            next if holder.is_a?(PokeBattle_Battler) && holder.index == @index
            holder.effects.each do |effect, value|
                effectData = GameData::BattleEffect.get(effect)
                next unless effectData.type == :Position
                next unless effectData.others_lose_track
                next unless value == @index
                echoln("[BATTLER EFFECT] Effect #{effect} in holder #{holder} stops pointing to battler #{name} (#{@index}) due to it exiting")
                holder.disableEffect(effect)
            end
        end

        # Cause other battlers to reset effects that were contingent on this battler
        # Remaining on the battlefield (e.g. trapping)
        @battle.eachBattler do |b|
            next if b.index == @index
            b.eachEffect(true) do |_effect, value, data|
                next if data.type != :Position
                next if value != @index
                next if data.deep_teeth? && deepTeeth
                data.disable_effects_on_other_exit.each do |effectToDisable|
                    echoln("[BATTLER EFFECT] Effect #{effectToDisable} is disabled on #{b.name} due to #{name} (#{@index}) exiting")
                    b.disableEffect(effectToDisable)
                end
            end
        end

        if batonPass
            # Don't reset stats
        else
            resetStatSteps
        end

        resetTrackers
    end

    def initializeEffects(batonPass = false)
        # Reset values, accounting for baton pass
        GameData::BattleEffect.each_battler_effect do |effectData|
            effectID = effectData.id
            # Reset the value to its default
            # Unless its a baton passable value and we are baton passing
            if batonPass && effectData.baton_passed
                currentValue = @effects[effectID]
                newValue = effectData.baton_pass_value(self, currentValue)
                @effects[effectID] = newValue
            else
                @effects[effectID] = effectData.default
            end
            effectData.initialize_battler(@battle, self)
        end
    end

    def resetStatSteps
        @steps[:ATTACK] = 0
        @steps[:DEFENSE]         = 0
        @steps[:SPEED]           = 0
        @steps[:SPECIAL_ATTACK]  = 0
        @steps[:SPECIAL_DEFENSE] = 0
        @steps[:ACCURACY]        = 0
        @steps[:EVASION]         = 0
    end

    def resetTrackers
        @fainted               = @hp.zero? || @pokemon.afraid?
        @initialHP             = 0
        @lastAttacker          = []
        @lastFoeAttacker       = []
        @lastHPLost            = 0
        @lastHPLostFromFoe     = 0
        @lastRoundHighestTypeModFromFoe = -1
        @tookDamage            = false
        @tookPhysicalHit       = false
        @tookSpecialHit        = false
        @tookPhysicalHitLastRound = false
        @tookSpecialHitLastRound = false
        @moveUsageHistory      = []
        @lastMoveUsed          = nil
        @lastMoveUsedType      = nil
        @lastMoveUsedCategory  = -1
        @usedDamagingMove      = false
        @lastRoundMove = nil
        @lastRoundMoveType     = nil
        @lastRoundMoveCategory = -1
        @lastRegularMoveUsed   = nil
        @lastRegularMoveTarget = -1
        @lastRoundMoved        = -1
        @lastMoveFailed        = false
        @lastRoundMoveFailed   = false
        @movesUsed             = []
        @turnCount             = 0

        # Boss stuff
        @avatarPhase           = 1
        @empoweredTimer		   = 0
        @extraMovesPerTurn = 0
        @indicesTargetedRoundBeforeLast = []
        @indicesTargetedLastRound = []
        @indicesTargetedThisRound = []
    end

    #=============================================================================
    # Refreshing a battler's properties
    #=============================================================================
    def pbUpdate(fullChange = false)
        return unless @pokemon
        hpDiff = @totalhp - @hp
        @pokemon.calc_stats
        @level          = @pokemon.level
        @totalhp        = @pokemon.totalhp
        @hp             = @pokemon.totalhp - hpDiff
        unless effectActive?(:Transform)
            @attack       = @pokemon.attack
            @defense      = @pokemon.defense
            @spatk        = @pokemon.spatk
            @spdef        = @pokemon.spdef
            @speed        = @pokemon.speed
            if fullChange
                unless @pokemon.bossType
                    @type1 = @pokemon.type1
                    @type2 = @pokemon.type2
                end
                @ability_id = @pokemon.ability_id
            end
        end
    end

    # Used to erase the battler of a Pokémon that has been caught.
    def pbReset
        @pokemon      = nil
        @pokemonIndex = -1
        @hp           = 0
        pbInitEffects(false)
        @participants = []
        # Reset status
        @status       = :NONE
        @statusCount  = 0
        # Reset choice
        @battle.pbClearChoice(@index)
    end

    # Update which Pokémon will gain Exp if this battler is defeated.
    def pbUpdateParticipants
        return if fainted? || !@battle.opposes?(@index)
        eachOpposing do |b|
            @participants.push(b.pokemonIndex) unless @participants.include?(b.pokemonIndex)
        end
    end

    def refreshDataBox
        return if @fake
        @battle.scene.pbRefreshOne(@index) if @battle.scene
    end

    def showMyAbilitySplash(abilityID, delay = false)
        @battle.pbShowAbilitySplash(self, abilityID, delay)
    end

    def hideMyAbilitySplash
        @battle.pbHideAbilitySplash(self)
    end
end
