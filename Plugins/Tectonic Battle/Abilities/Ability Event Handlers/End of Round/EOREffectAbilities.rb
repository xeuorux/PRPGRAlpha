BAD_DREAMS_DAMAGE_FRACTION = 0.125

BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |ability, battler, battle|
      battle.eachOtherSideBattler(battler.index) do |b|
          next if !b.near?(battler) || !b.asleep?
          battle.pbShowAbilitySplash(battler, ability)
          next unless b.takesIndirectDamage?(true)
          battle.pbDisplay(_INTL("{1} is pained by its dreams!", b.pbThis))
          b.applyFractionalDamage(BAD_DREAMS_DAMAGE_FRACTION, false)
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |ability, battler, battle|
      randomUp = []
      randomDown = []
      GameData::Stat.each_main_battle do |s|
          randomUp.push(s.id) if battler.pbCanRaiseStatStep?(s.id, battler)
          randomDown.push(s.id) if battler.pbCanLowerStatStep?(s.id, battler)
      end
      next if randomUp.length == 0 && randomDown.length == 0
      battle.pbShowAbilitySplash(battler, ability)
      if randomUp.length > 0
          r = battle.pbRandom(randomUp.length)
          randomUpStat = randomUp[r]
          battler.tryRaiseStat(randomUpStat, battler, increment: 3)
          randomDown.delete(randomUp[r])
      end
      if randomDown.length > 0
          r = battle.pbRandom(randomDown.length)
          randomDownStat = randomDown[r]
          battler.tryLowerStat(randomDownStat, battler)
      end
      battle.pbHideAbilitySplash(battler)
      battler.pbItemStatRestoreCheck if randomDown.length > 0
  }
)

BattleHandlers::EOREffectAbility.add(:PERSISTENTGROWTH,
  proc { |ability, battler, battle|
      next unless battler.turnCount > 0
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbRaiseMultipleStatSteps([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1], battler)
      battler.tryLowerStat(:SPEED, battler)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |ability, battler, _battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      battler.tryRaiseStat(:SPEED, battler, ability: ability, increment: 2) if battler.turnCount > 0
  }
)

BattleHandlers::EOREffectAbility.add(:SPINTENSITY,
  proc { |ability, battler, _battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      battler.tryRaiseStat(:SPEED, battler, ability: ability) if battler.turnCount > 0
  }
)

BattleHandlers::EOREffectAbility.add(:HUNGERSWITCH,
  proc { |ability, battler, battle|
      if battler.species == :MORPEKO
          battle.pbShowAbilitySplash(battler, ability)
          battler.form = (battler.form == 0) ? 1 : 0
          battler.pbUpdate(true)
          battle.scene.pbChangePokemon(battler, battler.pokemon)
          battle.pbDisplay(_INTL("{1} transformed!", battler.pbThis))
          battler.refreshDataBox
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:LUXURYTASTE,
  proc { |ability, battler, battle|
      next unless battler.hasActiveItem?(GameData::Item.getByFlag("Clothing"))
      healingMessage = _INTL("{1} luxuriated in its fine clothing.", battler.pbThis)
      battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
  }
)

BattleHandlers::EOREffectAbility.add(:IGNITIONCYCLE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      if !battler.statStepAtMax?(:SPEED)
          if battler.tryRaiseStat(:SPEED, battler, increment: 3)
              battler.applyFractionalDamage(1.0 / 8.0, false)
              battle.pbDisplay(_INTL("{1}'s inner fire flared up!", battler.pbThis))
          end
      else
          battle.pbDisplay(_INTL("{1} finally cooled off!", battler.pbThis))
          battler.steps[:SPEED] = 0
          battler.pbRecoverHP(battler.totalhp - battler.hp)
      end

      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:EXTREMEPOWER,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyFractionalDamage(EOR_SELF_HARM_ABILITY_DAMAGE_FRACTION)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.copy(:EXTREMEPOWER,:EXTREMEVOLTAGE,:LIVEFAST,:BURDENED)

BattleHandlers::EOREffectAbility.add(:TENDERIZE,
  proc { |ability, battler, _battle|
      battler.eachOther do |b|
          next unless b.numbed?
          b.pbLowerMultipleStatSteps(DEFENDING_STATS_2, battler, ability: ability)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:SINKINGFEELING,
  proc { |ability, battler, _battle|
      battler.eachOther do |b|
          next unless b.waterlogged?
          b.pbLowerMultipleStatSteps(ATTACKING_STATS_2, battler, ability: ability)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:VITALRHYTHM,
  proc { |ability, battler, battle|
      canHealAny = false
      battler.eachAlly do |b|
        canHealAny = true if b.canHeal?
      end
      canHealAny = true if battler.canHeal?
      next unless canHealAny
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyFractionalHealing(1.0 / 16.0)
      battler.eachAlly do |b|
        b.applyFractionalHealing(1.0 / 16.0)
      end
      battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::EOREffectAbility.add(:FLOURISHING,
  proc { |ability, battler, battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      next if battler.turnCount == 0
      next unless %i[PUMPKABOO GOURGEIST].include?(battler.species)
      next if battler.form == 3
      battle.pbShowAbilitySplash(battler, ability)
      formChangeMessage = _INTL("#{battler.pbThis} grows one size bigger!")
      battler.pbChangeForm(battler.form + 1, formChangeMessage)
      battle.pbDisplay(_INTL("#{battler.pbThis} is fully grown!")) if battler.form == 3
      battle.pbHideAbilitySplash(battler)
  }
)

EOT_ABILITY_HEALING_FRACTION = 1.0 / 12.0

BattleHandlers::EOREffectAbility.add(:FIGHTINGVIGOR,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(EOT_ABILITY_HEALING_FRACTION, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:GROTESQUEVITALS,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(EOT_ABILITY_HEALING_FRACTION, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:SELFSUFFICIENT,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(EOT_ABILITY_HEALING_FRACTION, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:LIVINGARMOR,
  proc { |ability, battler, battle|
      battler.applyFractionalHealing(EOT_ABILITY_HEALING_FRACTION, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:PRIMEVALREGENERATOR,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(1.0 / 4.0, ability: ability)
  }
)

LIFELINE_HEALING_FRACTION = 1.0 / 20.0

BattleHandlers::EOREffectAbility.add(:LIFELINE,
  proc { |ability, battler, battle|
    healingAmount = battler.applyFractionalHealing(LIFELINE_HEALING_FRACTION, ability: ability)

    if healingAmount > 0
        potentialHeals = []
        battle.pbParty(battler.index).each_with_index do |pkmn,partyIndex|
            next unless pkmn
            next if pkmn.fainted?
            next if pkmn.hp == pkmn.totalhp
            next if battle.pbFindBattler(partyIndex, battler.index)
            potentialHeals.push(pkmn)
        end
        unless potentialHeals.empty?
            healTarget = potentialHeals.sample
            battle.pbDisplay(_INTL("#{battler.pbThis} also heals #{healTarget.name}!"))
            healTarget.healBy(healingAmount)
        end
    end
  }
)

NOXIOUS_DAMAGE_FRACTION = 1.0/12.0

BattleHandlers::EOREffectAbility.add(:NOXIOUS,
  proc { |ability, battler, battle|
    anyPresent = false
    battler.eachOther do |b|
      anyPresent = true
      break
    end
    next unless anyPresent
    battler.showMyAbilitySplash(ability)
    battler.eachOther do |b|
      if b.takesIndirectDamage?(true)
        battle.pbDisplay(_INTL("{1} is hurt by the noxious presence!", b.pbThis))
        b.applyFractionalDamage(NOXIOUS_DAMAGE_FRACTION, false)
      end
    end
    battler.hideMyAbilitySplash
  }
)

BattleHandlers::EOREffectAbility.add(:FIREFESTIVAL,
  proc { |ability, battler, battle|
    battler.showMyAbilitySplash(ability)
    battle.eachBattler do |b|
      if b.takesIndirectDamage?(true)
        battle.pbDisplay(_INTL("{1} is splashed with fire!", b.pbThis))
        bTypes = b.pbTypes(true)
        damageFraction = battle.getTypedHazardHPRatio(:FIRE, bTypes[0], bTypes[1], bTypes[2])
        b.applyFractionalDamage(damageFraction, false)
      end
    end
    battler.hideMyAbilitySplash
  }
)

BattleHandlers::EOREffectAbility.add(:AUTOSTRUCTURE,
  proc { |ability, battler, battle|
    battler.showMyAbilitySplash(ability)
    
    # Store the current stats
    currentStats = {
      :ATTACK => battler.base_attack,
      :DEFENSE => battler.base_defense,
      :SPECIAL_ATTACK => battler.base_special_attack,
      :SPECIAL_DEFENSE => battler.base_special_defense,
      :SPEED => battler.base_speed,
    }
    # Change the stats
    battler.applyEffect(:BaseAttack,currentStats[:SPEED])
    battler.applyEffect(:BaseDefense,currentStats[:ATTACK])
    battler.applyEffect(:BaseSpecialAttack,currentStats[:DEFENSE])
    battler.applyEffect(:BaseSpecialDefense,currentStats[:SPECIAL_ATTACK])
    battler.applyEffect(:BaseSpeed,currentStats[:SPECIAL_DEFENSE])

    battle.pbDisplay(_INTL("{1} has restructured!", battler.pbThis))
    battler.hideMyAbilitySplash
  }
)

DIRECT_CURRENT_HEALING_FRACTION = 1.0/5.0

BattleHandlers::EOREffectAbility.add(:DIRECTCURRENT,
  proc { |ability, battler, battle|
    if battler.pbCanLowerStatStep?(:SPECIAL_ATTACK, battler)
      battler.showMyAbilitySplash(ability)
      battler.tryLowerStat(:SPECIAL_ATTACK, battler)
      choices = [_INTL("Speed"),_INTL("Healing")]
      if battle.autoTesting
        choice = rand(1)
      elsif !battler.pbOwnedByPlayer? # Trainer AI
        choice = 0
      else
        choice = battle.scene.pbShowCommands(_INTL("Where to direct power?"),choices,0)
      end
      if choice == 0
        battler.tryRaiseStat(:SPEED, battler)
      else
        battler.applyFractionalHealing(DIRECT_CURRENT_HEALING_FRACTION)
      end
      battler.hideMyAbilitySplash
    end
  }
)