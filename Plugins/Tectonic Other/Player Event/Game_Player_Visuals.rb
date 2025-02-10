class Game_Player < Game_Character
    @@bobFrameSpeed = 1.0/15
    attr_accessor :opacity
  
    def fullPattern
      case self.direction
      when 2 then return self.pattern
      when 4 then return self.pattern + 4
      when 6 then return self.pattern + 8
      when 8 then return self.pattern + 12
      end
      return 0
    end
  
    def setDefaultCharName(chname,pattern,lockpattern=false)
      return if pattern<0 || pattern>=16
      @defaultCharacterName = chname
      @direction = [2,4,6,8][pattern/4]
      @pattern = pattern%4
      @lock_pattern = lockpattern
    end
  
    def pbCanRun?
      return false if $game_temp.in_menu
      return false if $game_temp.in_battle
      return false if @move_route_forcing
      return false if $game_temp.message_window_showing
      return false if pbMapInterpreterRunning?
      return false unless $Trainer.has_running_shoes
      return false if jumping?
      return false if $PokemonGlobal.diving
      return false if $PokemonGlobal.bicycle
      return false if $game_player.forcedWalkByTerrain?
      input = ($Options.runstyle == 1) ^ Input.press?(Input::ACTION)
      return input
    end
  
    def pbIsRunning?
      return moving? && !@move_route_forcing && pbCanRun?
    end
  
    def character_name
      @defaultCharacterName = "" if !@defaultCharacterName
      return @defaultCharacterName if @defaultCharacterName!=""
      if !@move_route_forcing && $Trainer.character_ID>=0
        meta = GameData::Metadata.get_player($Trainer.character_ID)
        if meta && !$PokemonGlobal.bicycle && !$PokemonGlobal.diving && !$PokemonGlobal.surfing
          charset = 1   # Display normal character sprite
          if pbCanRun? && (moving? || @wasmoving) && Input.dir4!=0 && meta[4] && meta[4]!=""
            charset = 4   # Display running character sprite
          end
          newCharName = pbGetPlayerCharset(meta,charset)
          @character_name = newCharName if newCharName
          @wasmoving = moving?
        end
      end
      return @character_name
    end

    def slowedByTerrain?
      return $game_map.slowingTerrain?(@x, @y, self)
    end

    def forcedWalkByTerrain?
      return $game_map.noRunTerrain?(@x, @y, self)
    end

    def canBikeOnTerrain?
      return !$game_map.noBikingTerrain?(@x, @y, self)
    end
  
    def update_command
      if $game_player.pbTerrainTag.ice
        # Maintain current speed
      elsif !moving? && !@move_route_forcing && $PokemonGlobal
        newMoveSpeed = 3
        if $PokemonGlobal.bicycle
          newMoveSpeed = 5   # Cycling
        elsif $PokemonGlobal.surfing
          newMoveSpeed = 4   # Surfing
        end
        newMoveSpeed += 1 if pbCanRun?
        newMoveSpeed -= 1 if slowedByTerrain?
        self.move_speed = newMoveSpeed
      end
      super
    end

    def move_speed=(val)
        return if val == @move_speed
        @move_speed = val
        # @move_speed_real is the number of quarter-pixels to move each frame. There
        # are 128 quarter-pixels per tile.
        realMoveSpeed = get_speed_from_speed_index(val)
        realMoveSpeed *= 1.5 if cellBoosterActive?
        self.move_speed_real = realMoveSpeed
    end
  
    def update_pattern
      if $PokemonGlobal.surfing || $PokemonGlobal.diving
        p = ((Graphics.frame_count%60)*@@bobFrameSpeed).floor
        @pattern = p if !@lock_pattern
        @pattern_surf = p
        @bob_height = (p>=2) ? 2 : 0
      else
        @bob_height = 0
        super
      end
    end
end

def cellBoosterActive?
    return $PokemonBag && pbHasItem?(:CELLBOOSTER)
end