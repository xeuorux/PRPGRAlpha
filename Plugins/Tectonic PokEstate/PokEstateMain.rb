SaveData.register(:pokestate_tracker) do
	ensure_class :PokEstate
	save_value { $PokEstate }
	load_value { |value| $PokEstate = value }
	new_game_value { PokEstate.new }
end

class DexCompletionAwardHandlerHash < HandlerHash2
	def trigger(symbols, newAwardsArray, assumeGranted = false)
		handlers = @hash.reject{|key,value| symbols.include?(key)}
		handlers.each do |handlerID,handler|
			next if handler.nil?
			begin
				awardInfo = handler.call($Trainer.pokedex)
				if awardInfo && (assumeGranted || awardInfo[:amount] >= awardInfo[:threshold])
					awardInfo[:id] = handlerID
					newAwardsArray.push(awardInfo)
				end
			rescue
				pbMessage(_INTL("A recoverable error has occured. Please report the following to a programmer."))
				pbPrintException($!)
			end
		end

		return newAwardsArray
	end
end

class PokEstate
	attr_reader   :estate_box
	attr_reader   :estate_teleport
	attr_reader   :stories_progress
	attr_reader   :stories_count

	GrantAwards 			= DexCompletionAwardHandlerHash.new
	LoadDataDependentAwards = Event.new

	def initialize()
		@estate_box = 0
		@estate_teleport = nil
		@stories_progress = 0
		@stories_count = [1] * Settings::NUM_STORAGE_BOXES
		@awardsGranted = []
	end

	def awardsGranted()
		@awardsGranted = [] if @awardsGranted.nil?
		return @awardsGranted
	end

	def isInEstate?
		return $game_map.map_id == FALLBACK_MAP_ID || ESTATE_MAP_IDS.include?($game_map.map_id)
	end

	def estateFirstVisit()
		transferToEstate(0,0)
	end

	def transferToEstate(boxNum = 0,entrance=-1)
		@estate_box = boxNum
		background = $PokemonStorage[boxNum].background
		newMap = ESTATE_MAP_IDS[background] || FALLBACK_MAP_ID
		
		# Notate the current location if outside the estate
		if !isInEstate?
			@estate_teleport = [$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
		end
	
		# Transfer the player to the new spot
		echoln("Transferring player to estate or box number #{boxNum}")
		$game_temp.player_transferring = true
		$game_temp.player_new_map_id    = 	newMap
		if entrance == -1
			position = [$game_player.x, $game_player.y, $game_player.direction]
		else
			position = ESTATE_MAP_ENTRANCES[entrance]
		end
		position = position || ESTATE_MAP_ENTRANCES[entrance]
		$game_temp.player_new_x         =	position[0]
		$game_temp.player_new_y         = 	position[1]
		$game_temp.player_new_direction = 	position[2]
		Graphics.freeze
		$game_temp.transition_processing = true
		$game_temp.transition_name       = ""
	end
	
	def transferToWesterEstate()
		westerBox = estate_box - 1
		westerBox = Settings::NUM_STORAGE_BOXES-1 if westerBox < 0
		transferToEstate(westerBox,1)
	end
	
	def transferToEasterEstate()
		easterValue = estate_box + 1
		easterValue = 0 if easterValue >= Settings::NUM_STORAGE_BOXES
		transferToEstate(easterValue,2)
	end
	
	def teleportPlayerBack()
		if @estate_teleport.nil?
			pbMessage(_INTL("ERROR: Cannot find location to teleport you back to."))
			pbMessage(_INTL("Bringing you to the fallback return position."))
			$game_temp.player_transferring = true
			$game_temp.player_new_map_id    =  FALLBACK_RETURN_POSITION[0]
			$game_temp.player_new_x         =	FALLBACK_RETURN_POSITION[1]
			$game_temp.player_new_y         = 	FALLBACK_RETURN_POSITION[2]
			$game_temp.player_new_direction = 	Up
		else
			tele = @estate_teleport
			$game_temp.player_transferring = true
			$game_temp.player_new_map_id    = 	tele[0]
			$game_temp.player_new_x         =	tele[1]
			$game_temp.player_new_y         = 	tele[2]
			$game_temp.player_new_direction = 	tele[3]
		end
		Graphics.freeze
		$game_temp.transition_processing = true
		$game_temp.transition_name       = ""
	end
	
	def transferToEstateOfChoice()
		params = ChooseNumberParams.new
		params.setRange(1, Settings::NUM_STORAGE_BOXES)
		params.setDefaultValue(estate_box+1)
		params.setCancelValue(0)
		boxChoice = pbMessageChooseNumber(_INTL("Which plot would you like to visit?"),params)
		boxChoice -= 1
		return false if boxChoice <= -1
		return false if $PokemonStorage[boxChoice].isDonationBox?
		return false if isInEstate?() && boxChoice == estate_box
		transferToEstate(boxChoice,0)
		return true
	end
	
	def changeLandscape()
		papers = $PokemonStorage.availableWallpapers
		index = 0
		for i in 0...papers[1].length
			if papers[1][i]==$PokemonStorage[estate_box].background
				index = i; break
			end
		end
		papers[0].push(_INTL("Cancel"))
		chosenPaper = pbMessage(_INTL("Pick the landscape you'd like for this plot."),papers[0],papers[0].length,nil,index)
		return if chosenPaper == papers[0].length - 1 || chosenPaper == index
		$PokemonStorage[estate_box].background = chosenPaper
		transferToEstate(estate_box,3)
	end
	
	def truckChoices()
		commandLeaveEstate = -1
		commandGoToOtherPlot = -1
		commandCancel = -1
		commands = []
		commands[commandGoToOtherPlot = commands.length] = _INTL("Drive To Plot")
		commands[commandLeaveEstate = commands.length] = _INTL("Leave PokÉstate")
		commands[commandCancel = commands.length] = _INTL("Cancel")
		
		command = pbMessage(_INTL("What would you like to do?"),commands,commandCancel+1)
		
		if commandLeaveEstate > -1 && command == commandLeaveEstate
			teleportPlayerBack()
		elsif commandGoToOtherPlot > -1 && command == commandGoToOtherPlot
			transferToEstateOfChoice()
		end
	end

	def careTakerInteraction
		caretakerChoices()
	end

	def checkForAwards(inPerson = true)
		newAwards = findNewAwards()
		if newAwards.length != 0
			unless inPerson
				pbMessage(_INTL("..."))
				pbMessage(_INTL("You notice a voice message from {1}, the PokÉstate caretaker.",CARETAKER))
			end
			
			pbMessage(_INTL("Greetings, young master. I have good news."))

			if newAwards.length == 1
				pbMessage(_INTL("\\ME[Bug catching 2nd]You've earned a new PokéDex completion reward!\\wtnp[60]"))
			else
				pbMessage(_INTL("\\ME[Bug catching 2nd]You've earned {1} new PokéDex completion rewards!\\wtnp[60]",newAwards.length))
			end
			
			if newAwards.length == 1
				awardDescription = newAwards[0][:description]
				pbMessage(_INTL("For collecting #{awardDescription}, please take this."))
			elsif newAwards.length <= 5
				pbMessage(_INTL("I'll list the feats you've accomplished:"))
				newAwards.each_with_index do |newAwardInfo, index|
					awardReward = newAwardInfo[:reward]
					awardDescription = newAwardInfo[:description]
					
					if index == 0
						pbMessage(_INTL("You've collected #{awardDescription}..."))
					elsif index == newAwards.length - 1
						pbMessage(_INTL("...and #{awardDescription}."))
					else
						pbMessage(_INTL("...#{awardDescription}..."))
					end
				end
			else
				if inPerson
					pbMessage(_INTL("That's so many! I'll just give you all the rewards at once."))
				else
					pbMessage(_INTL("That's a lot, so I've lumped all the rewards together."))
				end
			end

			pbMessage(_INTL("As you finish reading, the PC materializes a package...")) unless inPerson

			itemsToGrantHash = {}
			newAwards.each do |newAwardInfo|
				awardReward = newAwardInfo[:reward]
				awardDescription = newAwardInfo[:description]

				# Tally the items to give out
				itemCount = 1
				if awardReward.is_a?(Array)
					itemGrant = awardReward[0]
					itemCount = awardReward[1]
				else
					itemGrant = awardReward
				end

				if !itemsToGrantHash.has_key?(itemGrant)
					itemsToGrantHash[itemGrant] = itemCount
				else
					itemsToGrantHash[itemGrant] += itemCount
				end

				# Mark this reward as having been granted
				self.awardsGranted.push(newAwardInfo[:id])
			end
			itemsToGrantHash.each do |item,count|
				pbReceiveItem(item,count)
			end
		end
	end

	def awardGranted?(awardID)
		return self.awardsGranted.include?(awardID)
	end

	def findNewAwards
		# Load all data dependent events
		LoadDataDependentAwards.trigger
        $Trainer.pokedex.resetOwnershipCache
		newAwardsArray = []
		newAwardsArray = GrantAwards.trigger(self.awardsGranted,newAwardsArray)
		return newAwardsArray
	end

	def resetAwards
		@awardsGranted = []
	end

    def getAwardsCompletionState
        LoadDataDependentAwards.trigger
        $Trainer.pokedex.resetOwnershipCache
        awardsArray = []
        awardsArray = GrantAwards.trigger([],awardsArray,true)
		return awardsArray
    end
	
	def caretakerChoices()
		commandLandscape = -1
        commandCheckRewards = -1
		commandReceiveUpdate = -1
		commandCancel = -1
		commandScrubAwards = -1
		commands = []
		commands[commandLandscape = commands.length] = _INTL("Landscape")
        commands[commandCheckRewards = commands.length] = _INTL("Check Rewards")
		commands[commandReceiveUpdate = commands.length] = _INTL("Hear Story") if STORIES_FEATURE_AVAILABLE
		commands[commandCancel = commands.length] = _INTL("Cancel")
		
		setSpeaker(CARETAKER)
		command = pbMessage(_INTL("What would you like to do?"),commands,commandCancel+1)
		
		if commandLandscape > -1 && command == commandLandscape
			changeLandscape()
        elsif commandCheckRewards > -1 && command == commandCheckRewards
            pbFadeOutIn do
                collectionRewardsListScene = CollectionRewardsListScene.new
                screen = CollectionRewardsListScreen.new(collectionRewardsListScene)
                screen.pbStartScreen
            end
		elsif commandReceiveUpdate > -1 && command == commandReceiveUpdate
			tryHearStory()
		end
	end

	def load_estate_box()
		# Find all the pokemon that need to be represented
		unusedBoxPokes = []
		boxNum = estate_box
		for index in 0...$PokemonStorage.maxPokemon(boxNum)
		  pokemon = $PokemonStorage[boxNum][index]
		  next if pokemon.nil?
		  unusedBoxPokes.push(pokemon)
		end
		
		# Find the feeding bowl, if any
		feedingBowl = nil
		for event in $game_map.events.values
			if event.name.downcase.include?("feedingbowl")
				feedingBowl = event 
				break
			end
		end
	
		# Find the estate caretaker, if any
		for event in $game_map.events.values
			if event.name.downcase.include?("caretaker")
				convertEventToCaretaker(event,boxNum)
				break
			end
		end
	
		# Load all the pokemon into the placeholders
		events = $game_map.events.values.shuffle()
		for event in events
			next unless event.name.downcase.include?("boxplaceholder")
			if unusedBoxPokes.length != 0
				pokemon = unusedBoxPokes.delete_at(rand(unusedBoxPokes.length))
				convertEventToPokemon(event,pokemon)
			else
				# Scrub all others
				event.event.pages = [RPG::Event::Page.new]
				event.refresh
			end
		end
	end
	
	def convertEventToPokemon(event,pokemon)
		actualEvent = event.event
		
		species = pokemon.species
		form = pokemon.form
		speciesData = GameData::Species.get(species)
		
		originalPage = actualEvent.pages[0]
		
		displayedMessage = nil
	
		# Find a message comment, if present
		list = originalPage.list
		for i in 0...list.length
		  next if list[i].code!=108   # Comment (first line)
		  command = list[i].parameters[0]
		  for j in (i+1)...list.length
			break if list[j].code!=408   # Comment (continuation line)
			command += "\r\n"+list[j].parameters[0]
		  end
		  displayedMessage = command
		  displayedMessage.gsub!("\\P",pokemon.name)
		  break
		end
		
		# Create the first page, where the cry happens
		firstPage = RPG::Event::Page.new

		characterName = GameData::Species.ow_sprite_filename(pokemon.species,pokemon.form,pokemon.gender,pokemon.shiny?).gsub!("Graphics/Characters/","")
		firstPage.graphic.character_name = characterName

		beginWandering(firstPage,pokemon,originalPage.step_anime)
		firstPage.move_type = originalPage.move_type
		if originalPage.move_type == 1 # Random
			firstPage.graphic.direction = 2 + rand(4) * 2
			firstPage.direction_fix = false
		else
			firstPage.graphic.direction = originalPage.graphic.direction
			firstPage.direction_fix = originalPage.direction_fix
		end
		firstPage.trigger = 0 # Action button
		firstPage.list = []
		push_text(firstPage.list,displayedMessage) if displayedMessage
		push_script(firstPage.list,sprintf("Pokemon.play_cry(:%s, %d)",speciesData.id,form))
		push_script(firstPage.list,sprintf("$PokEstate.estateChoices(#{event.id},#{pokemon.personalID})",))
		push_end(firstPage.list)
		
		actualEvent.pages[0] = firstPage
		
		event.floats = floatingPokemon?(pokemon)
		
		event.refresh()
	end
	
	def convertEventToCaretaker(event,boxID)
		# Create the first page, where the cry happens
		firstPage = RPG::Event::Page.new
		caretakerSprite = CARETAKER_SPRITES[boxID % CARETAKER_SPRITES.length]
		firstPage.graphic.character_name = caretakerSprite
		firstPage.trigger = 0 # Action button
		firstPage.list = []
		push_text(firstPage.list,"Welcome back to the PokÉstate, young master.")
		push_script(firstPage.list,sprintf("setSpeaker(CARETAKER)",))
		push_script(firstPage.list,sprintf("$PokEstate.careTakerInteraction",))
		firstPage.list.push(RPG::EventCommand.new(0,0,[]))
		
		event.event.pages[0] = firstPage
		event.refresh()
	end
	
	def estateChoices(eventID=-1,personalID = -1)
		return if personalID < 0 || eventID < 0
		
		pokemon = nil
		currentBox = -1
		donationBox = false
		currentSlot = -1
		for box in -1...Settings::NUM_STORAGE_BOXES
			for slot in 0...$PokemonStorage.maxPokemon(box)
				pkmn = $PokemonStorage[box][slot]
				next if pkmn.nil?
				if pkmn.personalID == personalID
					pokemon = pkmn
					currentBox = box
					donationBox = true if box >= 40
					currentSlot = slot
					break
				end
			end
		end
	
		return if pokemon.nil?

		eventCalling = $game_system.map_interpreter.get_event(eventID)
		return if eventCalling.nil?
	
		commands = []
		cmdSummary = -1
		cmdTake = -1
		cmdInteract = -1
		cmdUseItem = -1
		cmdModify = -1
		cmdCancel = -1

		commands[cmdInteract = commands.length] = _INTL("Interact")
		commands[cmdTake = commands.length] 	= _INTL("Take") unless donationBox
		commands[cmdSummary = commands.length] 	= _INTL("View Summary")
		commands[cmdUseItem = commands.length] 	= _INTL("Use Item") unless donationBox
		commands[cmdModify = commands.length]	= _INTL("Modify") unless donationBox
		commands[cmdCancel = commands.length] 	= _INTL("Cancel")
		command = 0

		species = pokemon.species
		form = pokemon.form

		while true
			command = pbMessage(_INTL("What would you like to do with #{pokemon.name}?"),commands,commands.length,nil,command)
			if cmdSummary > -1 && command == cmdSummary
				pbFadeOutIn {
					scene = PokemonSummary_Scene.new
					screen = PokemonSummaryScreen.new(scene)
					screen.pbStartSingleScreen(pokemon)
				}
			elsif cmdTake > -1 && command == cmdTake
				if $Trainer.party_full?
					pbPlayDecisionSE
					pbMessage(_INTL("Party is full, choose a Pokemon to swap out."))
					pbChooseNonEggPokemon(1,3)
					chosenIndex = pbGet(1)
					next if chosenIndex == -1
					chosenPokemon = $Trainer.party[chosenIndex]
					chosenPokemon.heal
					$PokemonStorage[currentBox][currentSlot] = chosenPokemon
					$Trainer.party[chosenIndex] = pokemon
					pbMessage(_INTL("You pick #{pokemon.name} up and add it to your party."))
					pbMessage(_INTL("And place #{chosenPokemon.name} down into the Estate."))
					convertEventToPokemon(eventCalling,chosenPokemon)
					break
				else  
					$PokemonStorage[currentBox][currentSlot] = nil
					$Trainer.party[$Trainer.party.length] = pokemon
					pbMessage(_INTL("You pick #{pokemon.name} up and add it to your party."))
					eventCalling.event.pages[0] = RPG::Event::Page.new
					eventCalling.refresh()
					break
				end
			elsif cmdInteract > -1 && command == cmdInteract
				prev_direction = eventCalling.direction
				eventCalling.direction_fix = false
				eventCalling.turn_toward_player
				if defined?(interactWithFollowerPokemon)
					interactWithFollowerPokemon(pokemon, eventCalling)
					pokemon.changeHappiness("interaction")
				end
				if rand < 0.5
					beginWandering(eventCalling.event.pages[0],pokemon)
					eventCalling.refresh
				else
					eventCalling.turn_generic(prev_direction)
				end
			elsif cmdUseItem > -1 && command == cmdUseItem
				item = selectItemForUseOnPokemon($PokemonBag,pokemon)
				next unless item
				pbUseItemOnPokemon(item,pokemon) 
				if pokemon.form != form || pokemon.species != species
					convertEventToPokemon(eventCalling,pokemon)
					break
				end
			elsif cmdModify > -1 && command == cmdModify
				break if modifyCommandMenu(eventCalling,pokemon,donationBox)
			elsif cmdCancel > -1 && command == cmdCancel
				break
			end
		end
	end

	# Return whether to exit the interaction menu
	def modifyCommandMenu(eventCalling,pokemon,donationBox=false)
		commands   = []
		cmdRename  = -1
		cmdSwapPokeBall = -1
		cmdEvolve  = -1
		cmdStyle = -1
		cmdOmnitutor = -1
		cmdCancel = -1

		commands[cmdRename = commands.length] 	= _INTL("Rename") unless donationBox
		commands[cmdSwapPokeBall = commands.length]   = _INTL("Swap Ball")
		newspecies = pokemon.check_evolution_on_level_up(false)
		commands[cmdEvolve = commands.length]   = _INTL("Evolve") if newspecies
		commands[cmdStyle = commands.length]  	= _INTL("Set Style") if pbHasItem?(:STYLINGKIT)

		if $PokemonGlobal.omnitutor_active && !getOmniMoves(pokemon).empty?
			commands[cmdOmnitutor = commands.length]	= _INTL("OmniTutor")
		end
		commands[cmdCancel = commands.length] = _INTL("Cancel")

		modifyCommand = 0
		modifyCommand = pbMessage(_INTL("Do what with {1}?", pokemon.name),commands,commands.length,nil,modifyCommand)
		if cmdRename > -1 && modifyCommand == cmdRename
			currentName = pokemon.name
			pbTextEntry("#{currentName}'s nickname?",0,Pokemon::MAX_NAME_SIZE,5)
			if pbGet(5)=="" || pbGet(5) == currentName
			  pokemon.name = currentName
			else
			  pokemon.name = pbGet(5)
			end
			convertEventToPokemon(eventCalling,pokemon)
		elsif cmdSwapPokeBall >= 0 && modifyCommand == cmdSwapPokeBall
			pokemon.switchBall
		elsif cmdEvolve > -1 && modifyCommand == cmdEvolve
			newspecies = pokemon.check_evolution_on_level_up(true)
			return true if newspecies.nil?
			pbFadeOutInWithMusic do
				evo = PokemonEvolutionScene.new
				evo.pbStartScreen(pokemon, newspecies)
				evo.pbEvolution
				evo.pbEndScreen
				convertEventToPokemon(eventCalling,pokemon)
				eventCalling.turn_toward_player
				return true
			end
		elsif cmdStyle >= 0 && modifyCommand == cmdStyle
			pbStyleValueScreen(pokemon)
		elsif cmdOmnitutor >= 0 && modifyCommand == cmdOmnitutor
			omniTutorScreen(pokemon)
		elsif cmdCancel > -1 && modifyCommand == cmdCancel
			return true
		end
		return false
	end
	
	def beginWandering(page,pokemon,stepAnimation=false)
		speciesData = GameData::Species.get(pokemon.species)
		page.direction_fix = false
		page.move_type = 1 # Random
		page.step_anime = stepAnimation || floatingPokemon?(pokemon)
		page.move_frequency = [[speciesData.base_stats[:SPEED] / 25,0].max,5].min
	end
	
	def setDownIntoEstate(pokemon)
		return unless isInEstate?()
		
		if $Trainer.able_pokemon_count == 1 && !pokemon.fainted?
			pbMessage(_INTL("Can't set down your last able Pokemon!"))
			return false
		end
	
		box = $PokemonStorage[@estate_box]
		if box.full?
			pbMessage(_INTL("Can't set #{pokemon.name} down into the current Estate plot because it is full."))
			return false
		end
		
		dir = $game_player.direction
		x = $game_player.x
		y = $game_player.y
		case dir
		when Up
			y -= 1
		when Right
			x += 1
		when Left
			x -= 1
		when Down
			y += 1
		end
		
		if !$game_map.passableStrict?(x,y,dir)
			pbMessage(_INTL("Can't set #{pokemon.name} down, the spot in front of you is blocked."))
			return false
		end
		
		pokemon.heal
		
		# Place the pokemon into the box
		for i in 0..box.length
			next if !box[i].nil?
			box[i] = pokemon
			break
		end
	
		promptToTakeItems(pokemon)
		
		# Put the pokemon into an event on the current map
		events = $game_map.events.values.shuffle()
		for event in events
			next unless event.name.downcase.include?("boxplaceholder")
			convertEventToPokemon(event,pokemon)
			event.moveto(x,y)
			event.direction = dir
			break
		end
		return true
	end

	def currentEstateBox()
		return nil if !isInEstate?
		return $PokemonStorage[@estate_box]
	end

	def incrementStoriesProgress()
		@stories_progress += 1
		if @stories_progress > STEPS_TILL_NEW_STORY
			@stories_progress = 0
			for box in -1...Settings::NUM_STORAGE_BOXES
				next if @stories_count[box] >= MAX_STORIES_STORAGE 
				count = 0
				$PokemonStorage[box].each { |pkmn| count += 1 if !pkmn.nil? }
				chance = NEW_STORY_PERCENT_CHANCE_PER_POKEMON * count
				if rand(100) < chance
					@stories_count[box] += 1 
				end
			end
		end
	end
 
	def tryHearStory()
		if currentEstateBox.empty?
			pbMessage(_INTL("There are no Pokemon in this plot to share stories about."))
		elsif @stories_count[@estate_box] <= 0
			pbMessage(_INTL("I regret to say that I have no stories to share about this plot. Please come back later."))
		else
			@stories_count[@estate_box] -= 1
			shareStory()
		end
	end

	def shareStory()
		if currentEstateBox.empty?
			return
		end

		if currentEstateBox.nitems == 1
			shareSingleStory(currentEstateBox.sample)
		elsif currentEstateBox.nitems > 1
			if rand(100) < 70
				shareSingleStory(currentEstateBox.sample)
			else
				randomPokemon1 = currentEstateBox.sample
				randomPokemon2 = nil
				loop do
					randomPokemon2 = currentEstateBox.sample
					break if randomPokemon2 != randomPokemon1
				end
				shareDuoStory(randomPokemon1, randomPokemon2)
			end
		end
	end

	def shareSingleStory(pokemon)
		pbMessage(_INTL("Story here involving {1}!",pokemon.name))
	end

	def shareDuoStory(pokemon1, pokemon2)
		pbMessage(_INTL("Story here involving {1} and {2}!", pokemon1.name, pokemon2.name))
	end
end

Events.onMapSceneChange += proc { |_sender, e|
	scene      = e[0]
	mapChanged = e[1]
	next if !scene || !scene.spriteset
	next unless $PokEstate.isInEstate?
	$PokEstate.load_estate_box
	boxName = $PokemonStorage[$PokEstate.estate_box].name
	label = _INTL("PokÉstate #{$PokEstate.estate_box +  1}")
	label += " - #{boxName}" if !boxName.eql?("Box #{$PokEstate.estate_box +  1}")
	scene.spriteset.addUserSprite(LocationWindow.new(label))
}

Events.onStepTaken += proc {
	$PokEstate.incrementStoriesProgress() if !$PokEstate.isInEstate?()
}

def transferToEasterEstate
	$PokEstate.transferToEasterEstate
end

def transferToWesterEstate
	$PokEstate.transferToWesterEstate
end