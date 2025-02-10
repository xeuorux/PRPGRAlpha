OASIS_SWITCHBOX_VAR = 43
OASIS_SYSTEM_MAP_ID = 406
INTEGRATION_CHAMBER_MAP_ID = 382

def electricFenceDectivates
    pbSEPlay("Anim/PRSFX- Paralysis", 100, 70)
end

def electricFenceActivates
    pbSEPlay("Anim/PRSFX- Paralysis", 100, 120)
end

def switchCurrent(eventIDs,toggleSelf=true)
    eventIDs = [eventIDs] unless eventIDs.is_a?(Array)  
    mainEvent = eventIDs[0]

    if toggleSelf
        pbSEPlay("GUI storage put down", 140, 70)
        toggleSwitch(get_self.id)
        pbWait(40)
    end

    slideCameraToEvent(mainEvent,5)

    255.downto(0) do |i|
        next if i % 3 != 0
        eventIDs.each do |eventID|
            get_character(eventID).opacity = i
        end
        pbWait(1)
    end

    pbSEPlay("Anim/PRSFX- Waterfall1", 100, 120)
    toggleSwitches(eventIDs)

    0.upto(255) do |i|
        next if i % 3 != 0
        eventIDs.each do |eventID|
            get_character(eventID).opacity = i
        end
        pbWait(1)
    end
    pbWait(20)
    slideCameraToPlayer(5)
end

##########################################################
### TUTORIAL
##########################################################

def circuitTutorialBasic(eventIDs)
    solved = circuitPuzzle(:TUTORIAL_BASIC)

    if solved
        setSwitchesAll(eventIDs,'A',true)
        electricFenceDectivates
    else
        setSwitchesAll(eventIDs,'A',false)
        electricFenceActivates
    end
end

def circuitTutorialResistors(eventIDs)
    solved = circuitPuzzle(:TUTORIAL_RESISTORS)

    if solved
        setSwitchesAll(eventIDs,'A',true)
        electricFenceDectivates
    else
        setSwitchesAll(eventIDs,'A',false)
        electricFenceActivates
    end
end

##########################################################
### WAVE LENGTH
##########################################################

def circuitWaveLengthExit(mapEventIDs,oasisEventIDs)
    solved = circuitPuzzle(:WL_EXIT)

    if solved
        setSwitchesAll(mapEventIDs,'A',true)
        setSwitchesAll(oasisEventIDs,'A',true,OASIS_SYSTEM_MAP_ID)
        incrementGlobalVar(OASIS_SWITCHBOX_VAR)
        electricFenceDectivates
    end
end

def circuitWaveLengthPrison(mapEventIDs,integrationEventIDs)
    solved = circuitPuzzle(:WL_PRISON)

    if solved
        setSwitchesAll(mapEventIDs,'A',true)
        setSwitchesAll(integrationEventIDs,'A',true,INTEGRATION_CHAMBER_MAP_ID)
        electricFenceDectivates
    end
end

##########################################################
### READ ONLY
##########################################################

def circuitReadOnlyExit(mapEventIDs,oasisEventIDs)
    solved = circuitPuzzle(:RO_EXIT)

    if solved
        setSwitchesAll(mapEventIDs,'A',true)
        setSwitchesAll(oasisEventIDs,'A',true,OASIS_SYSTEM_MAP_ID)
        incrementGlobalVar(OASIS_SWITCHBOX_VAR)
        electricFenceDectivates
    end
end

def circuitReadOnlyPrison(mapEventIDs,integrationEventIDs)
    solved = circuitPuzzle(:RO_PRISON)

    if solved
        setSwitchesAll(mapEventIDs,'A',true)
        setSwitchesAll(integrationEventIDs,'A',true,INTEGRATION_CHAMBER_MAP_ID)
        electricFenceDectivates
    end
end

##########################################################
### TERMINAL CONFUSION
##########################################################

def circuitTerminalConfusionExit(mapEventIDs,oasisEventIDs)
    solved = circuitPuzzle(:TC_EXIT)

    if solved
        setSwitchesAll(mapEventIDs,'A',true)
        setSwitchesAll(oasisEventIDs,'A',true,OASIS_SYSTEM_MAP_ID)
        electricFenceDectivates
    end
end

def circuitTerminalConfusionPrison(mapEventIDs,integrationEventIDs)
    solved = circuitPuzzle(:TC_PRISON)

    if solved
        setSwitchesAll(mapEventIDs,'A',true)
        setSwitchesAll(integrationEventIDs,'A',true,INTEGRATION_CHAMBER_MAP_ID)
        electricFenceDectivates
    end
end

##########################################################
### INTEGRATION CHAMBER
##########################################################
def circuitIntegrationChamberWave
    solved = circuitPuzzle(:IC_WAVE)

    if solved
        # TODO
    end
end

def circuitIntegrationChamberMaze
    solved = circuitPuzzle(:IC_ELECTRIC_MAZE)

    if solved
        # TODO
    end
end

def circuitIntegrationChamberAvatarCage
    solved = circuitPuzzle(:IC_AVATAR_CAGE)

    if solved
        # TODO
    end
end