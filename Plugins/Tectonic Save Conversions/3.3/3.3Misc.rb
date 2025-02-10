SaveData.register_conversion(:new_boss_loot_3_3_0) do
    game_version '3.3.0'
    display_title 'Adding new boss loot 3.3.0'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]
    
        itemBag.pbStoreItem(:VIPCARD, 1, false) if globalSwitches[127] # Defeated Avatar of Meloetta

        if globalSwitches[129] # Defeated Avatar of Yveltal
            itemBag.pbStoreItem(:OMINOUSEGG, 1, false)
            save_data[:global_metadata].ominous_egg_stage = 0
        end
        globalVariables[TRAINERS_PERFECTED_GLOBAL_VAR] = calculatePerfectedTrainerCount(selfSwitches)

        itemBag.pbStoreItem(:CHROMACLARION, 1, false) if globalSwitches[131] # Defeated Avatar of Xerneas

        # Exploded the dynamite stick at the end of the Foreclosed Tunnel
        itemBag.pbStoreItem(:SACCHARITEPICK, 1, false) if selfSwitches[[51,1,'A']]

        # Defeated the Avatar of Vigoroth in the Bluepoint Grotto
        itemBag.pbStoreItem(:SPANNINGBAND, 1, false) if selfSwitches[[26,4,'A']]

        # Move was replaced
        itemBag.pbChangeItem(:TMTRICKYTOXINS,:TMSHORTCIRCUIT)
    end
end

def calculatePerfectedTrainerCount(selfSwitches = nil)
    perfectTrainerCount = 0

    mapData = Compiler::MapData.new
    for id in mapData.mapinfos.keys.sort
        map = mapData.getMap(id)
        next if !map || !mapData.mapinfos[id]
        mapName = mapData.mapinfos[id].name
        for key in map.events.keys
            event = map.events[key]
            match = event.name.match(AUTO_FOLLOWER_NAME_FLAG_REGEX)
		    next unless match

            trainerClass = match[1].to_sym
            trainerName = match[2]
            trainerVersion = match[3].to_i || 0
            partyIndex = match[4].to_i || 0

            next if partyIndex != 0

            if selfSwitches
                next unless selfSwitches[[id,event.id,'D']]
            else
                next unless pbGetSelfSwitch(event.id,'D',id) # Fled
            end
            if trainerVersion > 0
                echoln("Perfected #{trainerClass} #{trainerName} v#{trainerVersion}")
            else
                echoln("Perfected #{trainerClass} #{trainerName}")
            end
            perfectTrainerCount += 1
        end
    end

    echoln("Perfected trainer count: #{perfectTrainerCount}")
    return perfectTrainerCount
end

def CPTC
    calculatePerfectedTrainerCount
end