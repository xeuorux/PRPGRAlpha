BattleHandlers::HPHealItem.add(:BERRYJUICE,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next false unless battler.canHeal?
      next false if !forced && battler.aboveHalfHealth?
      if filchedFrom
        battle.pbShowAbilitySplash(battler, filchingAbility)
        itemName = GameData::Item.get(item).name
        battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
      end
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem", battler) unless forced
      items_to_skip.push(item)
      battler.pbRecoverHP(20, items_to_skip: items_to_skip)
      if forced
          battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      else
          battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
      end
      battle.pbHideAbilitySplash(battler) if filchedFrom
      next true
  }
)


BattleHandlers::HPHealItem.add(:GANLONBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :DEFENSE, 2, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:APICOTBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :SPECIAL_DEFENSE, 2, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:LIECHIBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :ATTACK, 2, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:PETAYABERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :SPECIAL_ATTACK, 2, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:SALACBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :SPEED, 2, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:MICLEBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
    next pbBattleStatIncreasingBerry(battler, battle, item, forced, :ACCURACY, 4, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:LANSATBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next false if !forced && !battler.canConsumePinchBerry?
      next false if battler.effectAtMax?(:RaisedCritChance)
      if filchedFrom
        battle.pbShowAbilitySplash(battler, filchingAbility)
        itemName = GameData::Item.get(item).name
        battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
      end
      battle.pbCommonAnimation("Nom", battler) unless forced
      battler.incrementEffect(:RaisedCritChance, 2)
      battle.pbHideAbilitySplash(battler) if filchedFrom
      next true
  }
)

BattleHandlers::HPHealItem.add(:CADOBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next false unless battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(true)
      healFromBerry(battler, 1.0 / 3.0, item, forced, filchedFrom, filchingAbility, items_to_skip: items_to_skip)
      next true
  }
)

BattleHandlers::HPHealItem.add(:SITRUSBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next false unless battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      healFromBerry(battler, 1.0 / 4.0, item, forced, filchedFrom, filchingAbility, items_to_skip: items_to_skip)
      next true
  }
)

BattleHandlers::HPHealItem.add(:STARFBERRY,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      stats = []
      GameData::Stat.each_main_battle { |s| stats.push(s.id) if battler.pbCanRaiseStatStep?(s.id, battler) }
      next false if stats.length == 0
      stat = stats[battle.pbRandom(stats.length)]
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, stat, 3, true, filchedFrom, filchingAbility)
  }
)

BattleHandlers::HPHealItem.add(:WATERBALLOON,
  proc { |item, battler, battle, forced, filchedFrom, filchingAbility, items_to_skip|
      next false unless battler.belowHalfHealth?
      next false if battler.effectActive?(:AquaRing)
      battle.pbDisplay(_INTL("{1} dropped its {2}!", battler.pbThis, getItemName(item)))
      battler.applyEffect(:AquaRing)
      next true
  }
)