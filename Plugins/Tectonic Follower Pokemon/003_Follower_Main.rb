#-------------------------------------------------------------------------------
# Control the following Pokemon
# Example:
#     follower_move_route([
#         PBMoveRoute::TurnRight,
#         PBMoveRoute::Wait,4,
#         PBMoveRoute::Jump,0,0
#     ])
# The Pokemon turns Right, waits 4 frames, and then jumps
#-------------------------------------------------------------------------------
def follower_move_route(commands,waitComplete=false)
  return if !$Trainer.first_able_pokemon || !$PokemonGlobal.follower_toggled
  $PokemonTemp.dependentEvents.set_move_route(commands,waitComplete)
end

alias followingMoveRoute follower_move_route

#-------------------------------------------------------------------------------
# Script Command to toggle Following Pokemon
#-------------------------------------------------------------------------------
def pbToggleFollowingPokemon(forced = nil,anim = true)
  return if !pbGetFollowerDependentEvent
  return if !$Trainer.first_able_pokemon
  if !nil_or_empty?(forced)
    $PokemonGlobal.follower_toggled = true if forced[/on/i]
    $PokemonGlobal.follower_toggled = false if forced[/off/i]
  else
    $PokemonGlobal.follower_toggled = !($PokemonGlobal.follower_toggled)
  end
  $PokemonTemp.dependentEvents.refresh_sprite(anim)
end

#-------------------------------------------------------------------------------
# Script Command to start Pokemon Following. x is the Event ID that will be the follower
#-------------------------------------------------------------------------------
def pbPokemonFollow(x)
  return false if !$Trainer.first_able_pokemon
  $PokemonTemp.dependentEvents.removeEventByName("FollowerPkmn") if pbGetFollowerDependentEvent
  pbAddDependency2(x,"FollowerPkmn",FollowerSettings::FOLLOWER_COMMON_EVENT)
  $PokemonGlobal.follower_toggled = $Options.followers == 0
  event = pbGetFollowerDependentEvent
  $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps($game_player,event,true,false)
  $PokemonTemp.dependentEvents.refresh_sprite(true)
end

#-------------------------------------------------------------------------------
# Script Command for Talking to Following Pokemon
#-------------------------------------------------------------------------------
def pbTalkToFollower
  return false if !$PokemonTemp.dependentEvents.can_refresh?
  unless ($PokemonGlobal.surfing ||
       (GameData::MapMetadata.exists?($game_map.map_id) &&
       GameData::MapMetadata.get($game_map.map_id).always_bicycle) ||
       !$game_player.pbFacingTerrainTag.can_surf_freely? ||
       !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player))
    return false
  end
  first_pkmn = $Trainer.first_able_pokemon
  GameData::Species.play_cry(first_pkmn)
  echo GameData::Species.cry_filename_from_pokemon(first_pkmn)
  event = pbGetFollowerDependentEvent
  interactWithFollowerPokemon(first_pkmn,event)
  pbTurnTowardEvent(event,$game_player)
  first_pkmn.changeHappiness("interaction")
end

def interactWithFollowerPokemon(pokemon, event=nil)
  begin
    event = pbGetFollowerDependentEvent if event.nil?
    Events.OnTalkToFollower.trigger(pokemon,event,rand(6))
  rescue
    pbMessage(_INTL("An unknown error has occured."))
  end
end

#-------------------------------------------------------------------------------
# Script Command for getting the Following Pokemon Dependency
#-------------------------------------------------------------------------------
def pbGetFollowerDependentEvent
  return $PokemonTemp.dependentEvents.follower_dependent_event
end

#-------------------------------------------------------------------------------
# Script Command for removing every dependent event except Following Pokemon
#-------------------------------------------------------------------------------
def pbRemoveDependenciesExceptFollower
  $PokemonTemp.dependentEvents.remove_except_follower
end

#-------------------------------------------------------------------------------
# Script Command for  Pokémon finding an item in the field
#-------------------------------------------------------------------------------
def pbPokemonFound(item,quantity = 1,message = "")
  return false if !$PokemonGlobal.follower_hold_item
  pokename = $Trainer.first_able_pokemon.name
  message = "{1} seems to be holding something..." if nil_or_empty?(message)
  pbMessage(_INTL(message,pokename))
  item = GameData::Item.get(item)
  return false if !item || quantity<1
  itemname = (quantity>1) ? item.name_plural : item.name
  pocket = item.pocket
  move = item.move
  $PokemonGlobal.time_taken = 0
  $PokemonGlobal.follower_hold_item = false
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    meName = (item.is_key_item?) ? "Key item get" : "Item get"
    if item == :LEFTOVERS
      pbMessage(_INTL("\\me[{1}]#{pokename} found some \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    elsif item.is_machine?   # TM or HM
      pbMessage(_INTL("\\me[{1}]#{pokename} found \\c[1]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,GameData::Move.get(move).name))
    elsif quantity>1
      pbMessage(_INTL("\\me[{1}]#{pokename} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname))
    elsif itemname.starts_with_vowel?
      pbMessage(_INTL("\\me[{1}]#{pokename} found an \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    else
      pbMessage(_INTL("\\me[{1}]#{pokename} found a \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    end
    pbMessage(_INTL("#{pokename} put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  # Can't add the item
  if item == :LEFTOVERS
    pbMessage(_INTL("#{pokename} found some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("#{pokename} found \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,GameData::Move.get(move).name))
  elsif quantity>1
    pbMessage(_INTL("#{pokename} found {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("#{pokename} found an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  else
    pbMessage(_INTL("#{pokename} found a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  end
  pbMessage(_INTL("But your Bag is full..."))
  return false
end

#-------------------------------------------------------------------------------
# Adding a new method to GameData to easily get the appropriate Follower Graphic
#-------------------------------------------------------------------------------
module Compiler
  module_function

  def convert_pokemon_ows(src_dir, dest_dir)
    split = "Graphics/Characters/Followers/".split('/')
    for i in 0...split.size
      Dir.mkdir(split[0..i].join('/')) unless File.directory?(split[0..i].join('/'))
    end
    System.reload_cache
    split = "Graphics/Characters/Followers shiny/".split('/')
    for i in 0...split.size
      Dir.mkdir(split[0..i].join('/')) unless File.directory?(split[0..i].join('/'))
    end
    System.reload_cache
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon overworlds {1}/{2}...", i, files.length)) if i % 50 == 0
      next if !file[/^\d{3}[^\.]*\.[^\.]*$/]
      if file[/s/] && !file[/shadow/]
        prefix = "Followers shiny/"
      else
        prefix = "Followers/"
      end
      new_filename = convert_pokemon_filename(file,prefix)
      # moves the files into their appropriate folders
      File.move(src_dir + file, dest_dir + new_filename)
    end
  end

  if defined?(convert_files)
    class << self
      alias follower_convert_files convert_files
      def convert_files
        follower_convert_files
        convert_pokemon_ows("Graphics/Characters/","Graphics/Characters/")
        pbSetWindowText(nil)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Adding a new method to GameData to easily get the appropriate Follower Graphic
#-------------------------------------------------------------------------------
module SpriteRenamer
  module_function

  def convert_pokemon_ows(src_dir, dest_dir)
    split = "Graphics/Characters/Followers/".split('/')
    for i in 0...split.size
      Dir.mkdir(split[0..i].join('/')) unless File.directory?(split[0..i].join('/'))
    end
    System.reload_cache
    split = "Graphics/Characters/Followers shiny/".split('/')
    for i in 0...split.size
      Dir.mkdir(split[0..i].join('/')) unless File.directory?(split[0..i].join('/'))
    end
    System.reload_cache
    return if !FileTest.directory?(src_dir)
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon overworlds {1}/{2}...", i, files.length)) if i % 50 == 0
      next if !file[/^\d{3}[^\.]*\.[^\.]*$/]
      if file[/s/] && !file[/shadow/]
        prefix = "Followers shiny/"
      else
        prefix = "Followers/"
      end
      new_filename = convert_pokemon_filename(file,prefix)
      # moves the files into their appropriate folders
      File.move(src_dir + file, dest_dir + new_filename)
    end
  end

  if defined?(convert_files)
    class << self
      alias follower_convert_files convert_files
      def convert_files
        follower_convert_files
        convert_pokemon_ows("Graphics/Characters/","Graphics/Characters/")
        pbSetWindowText(nil)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Functions for handling the work that the variables did earlier
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_writer :follower_toggled
  attr_writer :time_taken
  attr_writer :follower_hold_item

  def call_refresh
    @call_refresh = [false,false] if !@call_refresh
    return @call_refresh
  end

  def call_refresh=(value)
    ret = value
    ret = [value,false] if !value.is_a?(Array)
    @call_refresh = value
  end

  def follower_toggled
    @follower_toggled = false if !@follower_toggled
    return @follower_toggled
  end

  def time_taken
    @time_taken = 0 if !@time_taken
    return @time_taken
  end

  def follower_hold_item
    @follower_hold_item = false if !@follower_hold_item
    return @follower_hold_item
  end
end

Events.onStepTaken += proc { |_sender,_e|
  if $PokemonGlobal.call_refresh[0]
    $PokemonTemp.dependentEvents.refresh_sprite($PokemonGlobal.call_refresh[1])
    $PokemonGlobal.call_refresh = [false,false]
  end
}

def refreshFollow(animate=true)
	return if $Options.followers == 1
	pbToggleFollowingPokemon("on",animate)
end