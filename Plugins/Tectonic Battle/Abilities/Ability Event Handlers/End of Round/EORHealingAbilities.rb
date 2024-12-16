BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
    proc { |ability, battler, battle|
        hasAnyRelevantStatus = false
        GameData::Status.each do |s|
            next unless battler.hasStatusNoTrigger(s.id)
            hasAnyRelevantStatus = true
            break
        end
        next unless hasAnyRelevantStatus
        battle.pbShowAbilitySplash(battler, ability)
        GameData::Status.each do |s|
            next if s.id == :NONE
            next if s.id == :SLEEP
            battler.pbCureStatus(true, s.id)
        end
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
    proc { |ability, battler, battle|
        next unless battler.hasAnyStatusNoTrigger
        next unless battle.rainy?
        battle.pbShowAbilitySplash(battler, ability)
        battler.pbCureStatus
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::EORHealingAbility.add(:HEALER,
    proc { |ability, battler, battle|
        battler.eachAlly do |b|
            next unless b.hasAnyStatusNoTrigger
            battle.pbShowAbilitySplash(battler, ability)
            b.pbCureStatus
            battle.pbHideAbilitySplash(battler)
        end
    }
)

BattleHandlers::EORHealingAbility.add(:OXYGENATION,
    proc { |ability, battler, battle|
        next unless battler.hasAnyStatusNoTrigger
        next unless battle.sunny?
        battle.pbShowAbilitySplash(battler, ability)
        battler.pbCureStatus
        battle.pbHideAbilitySplash(battler)
    }
)