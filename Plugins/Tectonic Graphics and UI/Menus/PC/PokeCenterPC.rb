#===============================================================================
#
#===============================================================================
module PokemonPCList
    @@pclist = []
  
    def self.registerPC(pc)
      @@pclist.push(pc)
    end
  
    def self.getCommandList
      commands = []
      for pc in @@pclist
        commands.push(pc.name) if pc.shouldShow?
      end
      commands.push(_INTL("Log Off"))
      return commands
    end
  
    def self.callCommand(cmd)
      return false if cmd<0 || cmd>=@@pclist.length
      i = 0
      for pc in @@pclist
        next if !pc.shouldShow?
        if i==cmd
          pc.access
          return true
        end
        i += 1
      end
      return false
    end
  end

def pbPokeCenterPC
    if !teamEditingAllowed?()
      showNoTeamEditingMessage()
      return
    end

    pbMessage(_INTL("\\se[PC open]The Pokémon Storage System was opened."))

    if pbHasItem?(:OMNIDRIVE) && !$PokemonGlobal.omnitutor_active
        pbMessage(_INTL("\\ssYou insert the Omnidrive into the PC."))
        pbMessage(_INTL("\\ssLoading Omni-Tutor..."))
        pbMessage(_INTL(".\\|.\\|.\\|.\\|.\\|"))
        pbMessage(_INTL("\\ssOmniTutor now engaged."))
        pbMessage(_INTL("\\ssThe OmniTutor can teach any move available through move reminding, move mentorship, and TMs you own."))
        $PokemonGlobal.omnitutor_active = true
    end

    $PokEstate.checkForAwards(false) unless getGlobalSwitch(ESTATE_DISABLED_SWITCH)

    command = 0
    loop do
        commands = []
        organizeCommand = -1
        widthdrawCommand = -1
        depositCommand = -1
        omniTutorCommand = -1
        visitEstateCommand = -1
        logOutCommand = -1
        commands[organizeCommand = commands.length] = _INTL("Organize Boxes")
        commands[widthdrawCommand = commands.length] = _INTL("Withdraw Pokémon") 
        commands[depositCommand = commands.length] = _INTL("Deposit Pokémon")
        commands[omniTutorCommand = commands.length] = _INTL("OmniTutor") if $PokemonGlobal.omnitutor_active 
        commands[visitEstateCommand = commands.length] = _INTL("Visit PokÉstate") unless getGlobalSwitch(ESTATE_DISABLED_SWITCH)
        commands[logOutCommand = commands.length] = _INTL("Log Out") 
        command = pbShowCommands(nil,commands,-1)
        if command == organizeCommand || command == widthdrawCommand || command == depositCommand
            if command==1   # Withdraw
                if $PokemonStorage.party_full?
                    pbMessage(_INTL("Your party is full!"))
                    next
                end
                elsif command==2   # Deposit
                    count=0
                    for p in $PokemonStorage.party
                        count += 1 if p && !p.egg? && p.hp>0
                    end
                    if count<=1
                        pbMessage(_INTL("Can't deposit the last Pokémon!"))
                    next
                end
            end
            pbFadeOutIn {
                scene = PokemonStorageScene.new
                screen = PokemonStorageScreen.new(scene,$PokemonStorage)
                return if screen.pbStartScreen(command)
            }
        elsif visitEstateCommand != -1 && command == visitEstateCommand
            break if $PokEstate.transferToEstateOfChoice()
        elsif omniTutorCommand != -1 && command == omniTutorCommand
            useOmniTutor()
        else
            break
        end
    end
    pbSEPlay("PC close")
    $PokemonTemp.dependentEvents.refresh_sprite(false)
end