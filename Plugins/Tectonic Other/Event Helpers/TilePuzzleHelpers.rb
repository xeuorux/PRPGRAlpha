def finishedTilePuzzleInteract
    pbPlayBuzzerSE
end

def boulderDisintegrates
    pbSEPlay("Anim/PRSFX- Sand Attack", 100, 50)
end

def tileReadOnly2x2(eventIDs)
    if pbTilePuzzle(1,"RO2x2",2,2)
        blackFadeOutIn{
            setSwitchesAll(eventIDs)
            setMySwitch
            boulderDisintegrates
        }
    end
end

def tileReadOnly3x3(eventIDs)
    if pbTilePuzzle(1,"RO3x3",3,3)
        blackFadeOutIn{
            setSwitchesAll(eventIDs)
            setMySwitch
            boulderDisintegrates
        }
    end
end

def tileReadOnly4x4(eventIDs)
    if pbTilePuzzle(1,"RO4x4",4,4)
        blackFadeOutIn{
            setSwitchesAll(eventIDs)
            setMySwitch
            boulderDisintegrates
        }
    end
end

def integrationChamber2x2(eventIDs)
    if pbTilePuzzle(1,"IC2x2",2,2)
        blackFadeOutIn{
            setSwitchesAll(eventIDs)
            setMySwitch
            boulderDisintegrates
        }
    end
end

def integrationChamber3x3(eventIDs)
    if pbTilePuzzle(1,"IC3x3",3,3)
        blackFadeOutIn{
            setSwitchesAll(eventIDs)
            setMySwitch
            boulderDisintegrates
        }
    end
end

def integrationChamber5x5(eventIDs)
    if pbTilePuzzle(1,"IC5x5",5,5)
        blackFadeOutIn{
            setSwitchesAll(eventIDs)
            setMySwitch
            boulderDisintegrates
        }
    end
end