#############################################################
# Adaption abilities
#############################################################
BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability, target, user, move, _switched, battle|
      next unless user.activatesTargetAbilities?
      next if target.damageState.calcDamage == 0 || target.damageState.substitute
      next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
      next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
      typeName = GameData::Type.get(move.calcType).name
      battle.pbShowAbilitySplash(target, ability)
      target.pbChangeTypes(move.calcType)
      battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!", target.pbThis, getAbilityName(ability), typeName))
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:INDESTRUCTIBLE,
  proc { |ability, target, _user, move, _switched, battle|
      next unless move.damagingMove?
      next if target.damageState.calcDamage == 0 || target.damageState.substitute
      next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
      battle.pbShowAbilitySplash(target, ability)
      target.disableEffect(:Indestructible)
      target.applyEffect(:Indestructible,move.calcType)
      battle.pbHideAbilitySplash(target)
  }
)

#############################################################
# Thieving abilities
#############################################################

BattleHandlers::TargetAbilityAfterMoveUse.add(:MONKEYMISCHIEF,
  proc { |ability, target, user, move, switched, battle|
      next if switched.include?(user.index)
      next unless move.damagingMove?
      next unless user.activatesTargetAbilities?
      next if battle.futureSight
      move.knockOffItems(target, user, ability: ability, firstItemOnly: true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MOONLIGHTER,
  proc { |ability, target, user, move, switched, battle|
      next if switched.include?(user.index)
      next unless move.damagingMove?
      next unless user.activatesTargetAbilities?
      next if battle.futureSight
      next unless battle.moonGlowing?
      item = user.firstItem
      if move.canStealItem?(user,target, item)
        move.stealItem(target, user, item, ability: ability)
      else
        move.knockOffItems(target, user, ability: ability, firstItemOnly: true)
      end
  }
)

#############################################################
# Every-hit punishers
#############################################################

BattleHandlers::TargetAbilityAfterMoveUse.add(:PLASMAGLOBE,
  proc { |ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next if target.damageState.unaffected
      next if target.damageState.totalHPLost <= 0
      battle.pbShowAbilitySplash(target, ability)
      unless user.takesIndirectDamage?(true)
        battle.pbHideAbilitySplash(target)
        next
      end
      user.pbReduceHP(target.damageState.totalHPLost, false)
      battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
      user.pbItemHPHealCheck
      user.pbFaint if user.fainted?
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:ABOVEITALL,
  proc { |ability, target, user, move, _switched, battle|
      next if target.fainted?
      next unless target.damageState.totalHPLost > 0
      battle.forceUseMove(target, :PARTINGSHOT, user.index, ability: ability)
  }
)