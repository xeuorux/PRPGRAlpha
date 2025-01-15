def takeDragonFlame(triggerEventID = -1)
    if candlePuzzlesCompleted?
        pbMessage(_INTL("The flame refuses to budge!"))
        return false
    end
    if $PokemonGlobal.dragonFlamesCount > 0
        pbMessage(_INTL("You are already holding a dragon flame!"))
        return false
    end
    if triggerEventID > 0
        if get_event(triggerEventID).at_coordinate?($game_player.x, $game_player.y)
            pbMessage(_INTL("The shadow will envelop you if you remove the flame now!"))
            return false
        end
    end
    pbSEPlay("Anim/PRSFX- Spirit Shackle3", 100, 150)
    invertMySwitch('A')
    createDragonFlameGraphic
    $PokemonGlobal.dragonFlamesCount += 1
    if triggerEventID > 0
        if get_event(triggerEventID).name[/DARKBLOCKINVERT/]
            unless pbGetSelfSwitch(triggerEventID,'A')
                fadeInDarknessBlock(triggerEventID)
                return true
            end
        else
            if pbGetSelfSwitch(triggerEventID,'A')
                fadeInDarknessBlock(triggerEventID)
                return true
            end
        end
    end
    return false
end

def giveDragonFlame(triggerEventID = -1, otherCandles = [])
    if $PokemonGlobal.dragonFlamesCount == 0
        pbMessage(_INTL("It looks like it could hold a magical flame."))
        return false
    end
    pbSEPlay("Anim/PRSFX- Spirit Shackle3", 100, 120)
    invertMySwitch('A')
    removeDragonFlameGraphic
    $PokemonGlobal.dragonFlamesCount -= 1
    ret = false
    if triggerEventID > 0
        allFlamesActive = true
        otherCandles.each do |candleEventID|
            next if get_event(candleEventID).name[/DRAGONCANDLEUNLIT/] && pbGetSelfSwitch(candleEventID,'A')
            next if get_event(candleEventID).name[/DRAGONCANDLELIT/] && !pbGetSelfSwitch(candleEventID,'A')
            allFlamesActive = false
            break
        end
        if allFlamesActive
            fadeOutDarknessBlock(triggerEventID, false)
            ret = true
        end

        if candlePuzzlesCompleted?($game_map.map_id)
            lockInCatacombs
        end
    end
    return ret
end

def createDragonFlameGraphic(spriteset = nil)
    newGraphic = LightEffect_DragonFlame.new($game_player,Spriteset_Map.viewport,$game_map)
    spriteset = $scene.spriteset if spriteset.nil?
    spriteset.addUserSprite(newGraphic)
    $PokemonTemp.dragonFlames.push(newGraphic)
end

def removeDragonFlameGraphic
    removedFlame = $PokemonTemp.dragonFlames.pop
    removedFlame.dispose
end

def removeAllDragonFlameGraphics
    until $PokemonTemp.dragonFlames.empty?
        removedFlame = $PokemonTemp.dragonFlames.pop
        removedFlame.dispose
    end
end

def candlePuzzlesCompleted?(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    case mapID
    when 282
        return pbGetSelfSwitch(14,"A",mapID) && pbGetSelfSwitch(12,"A",mapID)
    when 361
        return pbGetSelfSwitch(25,"A",mapID)
    when 362
        return pbGetSelfSwitch(42,"A",mapID)
    when 27
        return pbGetSelfSwitch(4,"A",mapID)
    end
    return false
end

CATACOMBS_MAPS_IDS = [282,361,362,27]

# Remove all dragon flames from player on map exit
Events.onMapChanging += proc { |_sender,e|
    newmapID = e[0]

    if !$game_map || newmapID == $game_map.map_id
        echoln("Skipping this map for dragon flame reset check, since its the same map as before")
        next
    end

    # Remove all the player's dragon flames
    $PokemonTemp.dragonFlames.each do |flame|
        flame.dispose
    end
    $PokemonTemp.dragonFlames.clear
    $PokemonGlobal.dragonFlamesCount = 0

    # If one of the catacombs maps
    if CATACOMBS_MAPS_IDS.include?(newmapID)
        unless candlePuzzlesCompleted?(newmapID)
            resetCatacombs(newmapID)
        else
            echoln("Not resetting this catacombs map #{newmapID}, its puzzle was completed")
        end
    end
}

def resetCatacombs(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    map = $MapFactory.getMapNoAdd(mapID)
    count = 0
    map.events.each_value do |event|
        eventName = event.name.downcase
        if eventName.include?("darkblock") || eventName.include?("dragoncandle") || eventName.include?("sewageflip")
            pbSetSelfSwitch(event.id,"A",false,mapID)
            count += 1
        end
    end
    $PokemonGlobal.dragonFlamesCount = 0
    removeAllDragonFlameGraphics
    echoln("Reset map #{mapID}'s #{count} dragon flame puzzle events")
end

def disableCatacombs(mapID = -1)
    mapID = $game_map.map_id if mapID == -1
    map = $MapFactory.getMapNoAdd(mapID)
    count = 0
    map.events.each_value do |event|
        eventName = event.name.downcase
        if eventName.include?("darkblock") || eventName.include?("dragoncandlelit")
            pbSetSelfSwitch(event.id,"A",true,mapID)
            count += 1
        elsif eventName.include?("dragoncandleunlit")
            pbSetSelfSwitch(event.id,"A",false,mapID)
            count += 1
        end
    end
    echoln("Disabled map #{mapID}'s #{count} dragon flame puzzle events")
end

def lockInCatacombs
    pbWait(20)
    pbSEPlay("Anim/PRSFX- Hypnosis", 120, 80)
    $game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
    pbWait(2 * Graphics.frame_rate)
    pbSEPlay("Anim/PRSFX- DiamondStorm6", 150, 80)
    disableCatacombs
    pbWait(20)
end

def hasDragonFlame?
    return $PokemonGlobal.dragonFlamesCount > 0
end

def toggleAllSewageFlips(switchName = 'A')
    blackFadeOutIn(20) {
        pbSEPlay("Anim/PRSFX- Sludge Bomb2",80,65)
        mapid = $game_map.map_id
        for event in $game_map.events.values
            next unless event.name[/sewageflip/]
            currentValue = $game_self_switches[[mapid, event.id, switchName]]
            $game_self_switches[[mapid, event.id, switchName]] = !currentValue
        end
        $MapFactory.getMap(mapid, false).need_refresh = true
    }
end