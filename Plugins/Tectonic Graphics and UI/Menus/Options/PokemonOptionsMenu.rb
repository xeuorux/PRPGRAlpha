class PokemonOptionMenu < PokemonPauseMenu
	def pbStartPokemonMenu
		@scene.pbStartScene
		endscene = true
		cmdAudioOptions = -1
		cmdUIOptions = -1
    cmdBattleOptions = -1
    cmdOverworldOptions = -1
    cmdAdvancedGraphicsOptions = -1
    cmdPlayerAppearance = -1
    cmdControlsMapping = -1
    cmdLanguageSelect = -1
    cmdCancel = -1
    optionsCommands = []
    optionsCommands[cmdUISpeedOptions = optionsCommands.length] = _INTL("Speed Options")
		optionsCommands[cmdBattleOptions = optionsCommands.length] = _INTL("Battle Options")
    optionsCommands[cmdUIOptions = optionsCommands.length] = _INTL("UI Options")
		optionsCommands[cmdOverworldOptions = optionsCommands.length] = _INTL("Overworld Options")
    optionsCommands[cmdAudioOptions = optionsCommands.length] = _INTL("Audio Options")
    optionsCommands[cmdAdvancedGraphicsOptions = optionsCommands.length] = _INTL("Adv. Graphics Options")
    optionsCommands[cmdPlayerAppearance = optionsCommands.length]  = _INTL("Player Appearance") if $scene.is_a?(Scene_Map)
    optionsCommands[cmdControlsMapping = optionsCommands.length] = _INTL("Controls")
    optionsCommands[cmdLanguageSelect = optionsCommands.length] = _INTL("Language")
    optionsCommands[cmdCancel = optionsCommands.length] = _INTL("Cancel")
		loop do
			infoCommand = @scene.pbShowCommands(optionsCommands)
      break if infoCommand < 0 || infoCommand == cmdCancel
      if cmdPlayerAppearance > 0 && infoCommand == cmdPlayerAppearance
        selectPlayerAppearance
        next
      elsif cmdLanguageSelect > 0 && infoCommand == cmdLanguageSelect
          prevLanguage = $Options.language
          $Options.language = pbChooseLanguage
          if $Options.language == prevLanguage
              pbMessage(_INTL("Game language was unchanged."))
          else
              loadLanguage
              languageName = Settings::LANGUAGES[$Options.language][0]
              pbMessage(_INTL("Game language changed to {1}!",languageName))
          end
          next
      elsif cmdControlsMapping > 0 && infoCommand == cmdControlsMapping
          System.show_settings
          break
      end
      optionsScene = [
          PokemonOption_Scene_Speed,
          PokemonOption_Scene_Battle,
          PokemonOption_Scene_UserInterface,
          PokemonOption_Scene_Overworld,
          PokemonOption_Scene_Audio,
          PokemonOption_Scene_AdvancedGraphics,
      ][infoCommand]
      pbPlayDecisionSE
      pbFadeOutIn {
          scene = optionsScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
          $Options.storeOptions
      }
		end
		@scene.pbEndScene if endscene
	end
end