#===============================================================================
# Starts sunny weather. (Sunshine)
#===============================================================================
class PokeBattle_Move_StartSunshine8 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Sunshine
    end
end

# Empowered Sunshine
class PokeBattle_Move_EmpoweredSunshine < PokeBattle_Move_StartSunshine8
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
        transformType(user, :FIRE)
    end
end

#===============================================================================
# Burns the target and sets Sun
#===============================================================================
class PokeBattle_Move_BurnTargetStartSunshine8 < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Sunshine
        @durationSet = 8
        @statusToApply = :BURN
    end
end

#===============================================================================
# Starts rainy weather. (Rain)
#===============================================================================
class PokeBattle_Move_StartRainstorm8 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Rainstorm
    end
end

# Empowered Rain
class PokeBattle_Move_EmpoweredRainstorm < PokeBattle_Move_StartRainstorm8
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.pbAnimation(:AQUARING, user, [user])
        user.applyEffect(:AquaRing)
        transformType(user, :WATER)
    end
end

#===============================================================================
# Waterlogs the target and sets Rain
#===============================================================================
class PokeBattle_Move_WaterlogTargetStartRainstorm8 < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Rainstorm
        @durationSet = 8
        @statusToApply = :WATERLOG
    end
end

#===============================================================================
# Starts sandstorm weather. (Sandstorm)
#===============================================================================
class PokeBattle_Move_StartSandstorm8 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
    end
end

# Empowered Sandstorm
class PokeBattle_Move_EmpoweredSandstorm < PokeBattle_Move_StartSandstorm8
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        transformType(user, :ROCK)
    end
end

#===============================================================================
# Dizzies the target and sets Sandstorm
#===============================================================================
class PokeBattle_Move_DizzyTargetStartSandstorm8 < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
        @durationSet = 8
        @statusToApply = :DIZZY
    end
end

#===============================================================================
# Starts hail weather. (Hail)
#===============================================================================
class PokeBattle_Move_StartHail8 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
    end
end

# Empowered Hail
class PokeBattle_Move_EmpoweredHail < PokeBattle_Move_StartHail8
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.tryLowerStat(:SPEED, user, increment: 2, move: self)
        end
        transformType(user, :ICE)
    end
end

#===============================================================================
# Frostbites the target and sets Hail
#===============================================================================
class PokeBattle_Move_FrostbiteTargetStartHail8 < PokeBattle_InviteMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
        @durationSet = 8
        @statusToApply = :FROSTBITE
    end
end

#===============================================================================
# Starts eclipse weather. (Eclipse)
#===============================================================================
class PokeBattle_Move_StartEclipse8 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Eclipse
    end
end

# Empowered Eclipse
class PokeBattle_Move_EmpoweredEclipse < PokeBattle_Move_StartEclipse8
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps([:ATTACK, 1, :SPECIAL_ATTACK, 1], user, move: self)
        transformType(user, :PSYCHIC)
    end
end

#===============================================================================
# Starts moonlight weather. (Moonglow)
#===============================================================================
class PokeBattle_Move_StartMoonglow8 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Moonglow
    end
end

# Empowered Moonglow
class PokeBattle_Move_EmpoweredMoonglow < PokeBattle_Move_StartMoonglow8
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        @battle.eachSameSideBattler(user) do |b|
            b.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        end

        transformType(user, :FAIRY)
    end
end