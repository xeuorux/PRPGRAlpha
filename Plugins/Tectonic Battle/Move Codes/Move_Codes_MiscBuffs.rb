#===============================================================================
# For 5 rounds, user becomes airborne. (Magnet Rise)
#===============================================================================
class PokeBattle_Move_StartUserAirborne5 < PokeBattle_Move
    def unusableInGravity?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Ingrain)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots keep it stuck in the ground!"))
            end
            return true
        end
        if user.effectActive?(:SmackDown)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} was smacked down to the ground!"))
            end
            return true
        end
        if user.effectActive?(:MagnetRise)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already risen up through magnetism!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:MagnetRise, 5)
    end

    def getEffectScore(user, _target)
        score = 20
        score += 20 if user.firstTurn?
        user.eachOpposing(true) do |b|
            if b.pbHasAttackingType?(:GROUND)
                score += 50
                score += 25 if b.pbHasType?(:GROUND)
            end
        end
        return score
    end
end

#===============================================================================
# Future attacks hits twice as many times (Volley Stance)
#===============================================================================
class PokeBattle_Move_StartUserHitsTwiceWithSpecial < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:VolleyStance)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already in a volley stance!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:VolleyStance)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore([:SPECIAL_ATTACK, 2], user, target) + 10
    end
end

#===============================================================================
# Raises the user's Sp. Atk by 3 steps, and the user's attacks become spread. (Flare Witch)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtk3StartUserAttacksSpread < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:FlareWitch) && !user.pbCanRaiseStatStep?(:SPECIAL_ATTACK, user, self, true)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't raise its Sp. Atk and already activated its witch powers!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self, increment: 3)
        user.applyEffect(:FlareWitch)
    end

    def getEffectScore(user, target)
        score = getMultiStatUpEffectScore([:SPECIAL_ATTACK,3], user, target)
        score += 30 unless user.effectActive?(:FlareWitch)
        return score
    end
end

#===============================================================================
# The user's attacks will all be critical hits for the next 3 turns.
# (Laser Focus)
#===============================================================================
class PokeBattle_Move_EnsureCriticalHits3 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.applyEffect(:LaserFocus, 4)
        @battle.pbDisplay(_INTL("{1} concentrated intensely!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:LaserFocus)
        return 80
    end
end

# Empowered Laser Focus
class PokeBattle_Move_EmpoweredLaserFocus < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        user.applyEffect(:EmpoweredLaserFocus)
        transformType(user, :STEEL)
    end
end

#===============================================================================
# User takes half damage from Super Effective moves. (Inure)
#===============================================================================
class PokeBattle_Move_StartUserShedTypeWeaknesses < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Inured)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already inured!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Inured)
    end

    def getEffectScore(user, _target)
        if user.firstTurn?
            return 80
        else
            return 60
        end
    end
end