#===============================================================================
# Waterlogs the target.
#===============================================================================
class PokeBattle_Move_Waterlog < PokeBattle_WaterlogMove
end

# Empowered Waterlog
class PokeBattle_Move_EmpoweredWaterlog < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyWaterlog(user) if b.canWaterlog?(user, true, self)
        end
        transformType(user, :WATER)
    end
end