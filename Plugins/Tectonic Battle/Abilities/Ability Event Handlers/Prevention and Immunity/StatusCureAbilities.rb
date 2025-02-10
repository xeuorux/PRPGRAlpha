BattleHandlers::StatusCureAbility.add(:MENTALBLOCK,
  proc { |ability, battler|
      battle = battler.battle

      activate = false
      battler.eachEffect(true) do |_effect, _value, data|
          next unless data.is_mental?
          activate = true
          break
      end
      activate = true if battler.dizzy?

      if activate
          battle.pbShowAbilitySplash(battler, ability)
          # Disable all mental effects
          battler.eachEffect(true) do |effect, _value, data|
              next unless data.is_mental?
              battler.disableEffect(effect)
          end
          battler.pbCureStatus(true, :DIZZY) if battler.dizzy?
          battle.pbHideAbilitySplash(battler)
      end
  }
)