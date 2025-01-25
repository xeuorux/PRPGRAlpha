
BattleHandlers::CriticalCalcUserAllyAbility.add(:SPECTRUMVISION,
    proc { |ability, user, _target, _move, c|
        next c + 1
    }
)
