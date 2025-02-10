BattleHandlers::CertainAddedEffectUserAbility.add(:STARSALIGN,
    proc { |ability, battle, user, target, move|
        next battle.eclipsed?
    }
)

BattleHandlers::CertainAddedEffectUserAbility.add(:TERRORIZE,
    proc { |ability, battle, user, target, move|
        next move.flinchingMove?
    }
)