TRAINERS_PERFECTED_GLOBAL_VAR = 79

GlobalStateHandlers::GlobalVariableChanged.add(TRAINERS_PERFECTED_GLOBAL_VAR,
    proc { |variableID, value|
        if $PokemonBag && pbHasItem?(:OMINOUSEGG)
            checkForOminousEggRewards
        end
    }
)

def receiveOminousEgg
    pbReceiveItem(:OMINOUSEGG)
    $PokemonGlobal.ominous_egg_stage = 0
    checkForOminousEggRewards
end

def checkForOminousEggRewards
    value = getGlobalVariable(TRAINERS_PERFECTED_GLOBAL_VAR)
    rewards = []

    if value >= 30 && $PokemonGlobal.ominous_egg_stage == 0
        rewards.push(:LIFEORB)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 60 && $PokemonGlobal.ominous_egg_stage == 1
        rewards.push(:PRISMSTONE)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 90 && $PokemonGlobal.ominous_egg_stage == 2
        rewards.push(:MASTERBALL)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 120 && $PokemonGlobal.ominous_egg_stage == 3
        rewards.push(:RELICSTATUE)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 150 && $PokemonGlobal.ominous_egg_stage == 4
        rewards.push(:SHINYCHARM)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    unless rewards.empty?
        playOminousEggCutscene

        rewards.each do |item|
            pbReceiveItem(item)
        end
    end
end

def playOminousEggCutscene
    pbWait(20)
    pbMessage(_INTL("\\i[OMINOUSEGG]...you hear whispers from the Ominous Egg."))
    pbWait(20)
    case $PokemonGlobal.ominous_egg_stage
    when 1
        pbMessage(_INTL("\\i[OMINOUSEGG]...sacrifice..."))
    when 2
        pbMessage(_INTL("\\i[OMINOUSEGG]...strength in avarice..."))
    when 3
        pbMessage(_INTL("\\i[OMINOUSEGG]...urge to dominate..."))
    when 4
        pbMessage(_INTL("\\i[OMINOUSEGG]...to stand above others..."))
    when 5
        pbMessage(_INTL("\\i[OMINOUSEGG]...nothing can hide from you..."))
    end
end