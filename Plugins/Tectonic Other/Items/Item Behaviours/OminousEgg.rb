TRAINERS_PERFECTED_GLOBAL_VAR = 79

GlobalStateHandlers::GlobalVariableChanged.add(TRAINERS_PERFECTED_GLOBAL_VAR,
    proc { |variableID, value|
        if pbHasItem?(:OMINOUSEGG)
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
    stage = $PokemonGlobal.ominous_egg_stage
    value = getGlobalVariable(TRAINERS_PERFECTED_GLOBAL_VAR)
    rewards = []

    if value >= 20 && stage == 0
        rewards.push(:LIFEORB)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 40 && stage == 1
        rewards.push(:MASTERBALL)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 60 && stage == 2
        rewards.push(:RELICSTATUE)
        $PokemonGlobal.ominous_egg_stage += 1
    end

    if value >= 80 && stage == 3
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
        pbMessage(_INTL("\\i[OMINOUSEGG]...urge to dominate..."))
    when 3
        pbMessage(_INTL("\\i[OMINOUSEGG]...to stand above others..."))
    when 4
        pbMessage(_INTL("\\i[OMINOUSEGG]...nothing can hide from you..."))
    end
end