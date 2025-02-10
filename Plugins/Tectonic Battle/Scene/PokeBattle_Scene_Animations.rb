class PokeBattle_Scene
    #=============================================================================
    # Animates the battle intro
    #=============================================================================
    def pbBattleIntroAnimation
      # Make everything appear
      introAnim = BattleIntroAnimation.new(@sprites,@viewport,@battle)
      loop do
        introAnim.update
        pbUpdate
        break if introAnim.animDone?
      end
      introAnim.dispose
      # Post-appearance activities
      # Trainer battle: get ready to show the party lineups (they are brought
      # on-screen by a separate animation)
      if @battle.trainerBattle?
        # NOTE: Here is where you'd make trainer sprites animate if they had an
        #       entrance animation. Be sure to set it up like a Pokémon entrance
        #       animation, i.e. add them to @animations so that they can play out
        #       while party lineups appear and messages show.
        pbShowPartyLineup(0,true)
        pbShowPartyLineup(1,true)
        return
      end
      # Wild battle: play wild Pokémon's intro animations (including cry), show
      # data box(es), return the wild Pokémon's sprite(s) to normal colour, show
      # shiny animation(s)
      # Set up data box animation
      for i in 0...@battle.sideSizes[1]
        idxBattler = 2*i+1
        next if !@battle.battlers[idxBattler]
        dataBoxAnim = DataBoxAppearAnimation.new(@sprites,@viewport,idxBattler)
        @animations.push(dataBoxAnim)
      end
      # Set up wild Pokémon returning to normal colour and playing intro
      # animations (including cry)
      @animations.push(BattleIntroAnimation2.new(@sprites,@viewport,@battle.sideSizes[1]))
      # Play all the animations
      while inPartyAnimation?; pbUpdate; end
      # Show shiny animation for wild Pokémon
      if @battle.showAnims
        for i in 0...@battle.sideSizes[1]
          idxBattler = 2*i+1
          next if !@battle.battlers[idxBattler] || !@battle.battlers[idxBattler].shiny?
          pbCommonAnimation("Shiny",@battle.battlers[idxBattler])
        end
      end
    end
  
    #=============================================================================
    # Animates a party lineup appearing for the given side
    #=============================================================================
    def pbShowPartyLineup(side,fullAnim=false)
      @animations.push(LineupAppearAnimation.new(@sprites,@viewport,
      side,@battle.pbParty(side),getDisplayBallCount(side),@battle.pbPartyStarts(side),fullAnim))
      if !fullAnim
      while inPartyAnimation?; pbUpdate; end
      end
    end
  
    #=============================================================================
    # Animates an opposing trainer sliding in from off-screen. Will animate a
    # previous trainer that is already on-screen slide off first. Used at the end
    # of battle.
    #=============================================================================
    def pbShowOpponent(idxTrainer)
      # Set up trainer appearing animation
      appearAnim = TrainerAppearAnimation.new(@sprites,@viewport,idxTrainer)
      @animations.push(appearAnim)
      # Play the animation
      while inPartyAnimation?; pbUpdate; end
    end
  
    #=============================================================================
    # Animates a trainer's sprite and party lineup hiding (if they are visible).
    # Animates a Pokémon being sent out into battle, then plays the shiny
    # animation for it if relevant.
    # sendOuts is an array; each element is itself an array: [idxBattler,pkmn]
    #=============================================================================
    def pbSendOutBattlers(sendOuts,startBattle=false)
      return if sendOuts.length==0
      # If party balls are still appearing, wait for them to finish showing up, as
      # the FadeAnimation will make them disappear.
      while inPartyAnimation?; pbUpdate; end
      @briefMessage = false
      # Make all trainers and party lineups disappear (player-side trainers may
      # animate throwing a Poké Ball)
      if @battle.opposes?(sendOuts[0][0])
        fadeAnim = TrainerFadeAnimation.new(@sprites,@viewport,getDisplayBallCount(1), startBattle)
      else
        fadeAnim = PlayerFadeAnimation.new(@sprites,@viewport,startBattle)
      end
      # For each battler being sent out, set the battler's sprite and create two
      # animations (the Poké Ball moving and battler appearing from it, and its
      # data box appearing)
      sendOutAnims = []
      sendOuts.each_with_index do |b,i|
        pkmn = @battle.battlers[b[0]].disguisedAs || b[1]
        pbChangePokemon(b[0],pkmn)
        pbRefresh
        if @battle.opposes?(b[0])
          sendOutAnim = PokeballTrainerSendOutAnimation.new(@sprites,@viewport,
            @battle.pbGetOwnerIndexFromBattlerIndex(b[0])+1,
            @battle.battlers[b[0]],startBattle,i)
        else
          sendOutAnim = PokeballPlayerSendOutAnimation.new(@sprites,@viewport,
            @battle.pbGetOwnerIndexFromBattlerIndex(b[0])+1,
            @battle.battlers[b[0]],startBattle,i)
        end
        dataBoxAnim = DataBoxAppearAnimation.new(@sprites,@viewport,b[0])
        sendOutAnims.push([sendOutAnim,dataBoxAnim,false])
      end
      # Play all animations
      loop do
        fadeAnim.update
        sendOutAnims.each do |a|
          next if a[2]
          a[0].update
          a[1].update if a[0].animDone?
          a[2] = true if a[1].animDone?
        end
        pbUpdate
        if !inPartyAnimation?
          break if !sendOutAnims.any? { |a| !a[2] }
        end
      end
      fadeAnim.dispose
      sendOutAnims.each { |a| a[0].dispose; a[1].dispose }
      # Play shininess animations for shiny Pokémon
      sendOuts.each do |b|
        next if !@battle.showAnims || !@battle.battlers[b[0]].shiny?
        pbCommonAnimation("Shiny",@battle.battlers[b[0]])
      end
    end
    
    def animateIntroNewAvatar(battlerIndexNew)
      # Animation of databox appearing
      dataBoxAnim = DataBoxAppearAnimation.new(@sprites, @viewport, battlerIndexNew)
      @animations.push(dataBoxAnim)
      # Set up wild Pokémon returning to normal colour and playing intro
      # animations (including cry)
      @animations.push(BattleIntroAnimationSolo.new(@sprites, @viewport, battlerIndexNew))
      # Play all the animations
      pbUpdate while inPartyAnimation?
    end

    def reviveBattler(idxBattler)
      # Animation of databox appearing
      dataBoxAnim = DataBoxAppearAnimation.new(@sprites, @viewport, idxBattler)
      @animations.push(dataBoxAnim)
      # Animation of new pokemon reviving
      reviveAnimation = PokemonReviveAnimation.new(@sprites, @viewport, @battle.battlers[idxBattler])
      @animations.push(reviveAnimation)
      # Play all the animations
      pbUpdate while inPartyAnimation?
    end
  
    #=============================================================================
    # Animates a Pokémon being recalled into its Poké Ball and its data box hiding
    #=============================================================================
    def pbRecall(idxBattler)
      @briefMessage = false
      # Recall animation
      recallAnim = BattlerRecallAnimation.new(@sprites,@viewport,idxBattler,@battle.battlers[idxBattler])
      loop do
        recallAnim.update if recallAnim
        pbUpdate
        break if recallAnim.animDone?
      end
      recallAnim.dispose
      # Data box disappear animation
      dataBoxAnim = DataBoxDisappearAnimation.new(@sprites,@viewport,idxBattler)
      loop do
        dataBoxAnim.update
        pbUpdate
        break if dataBoxAnim.animDone?
      end
      dataBoxAnim.dispose
    end
  
    #=============================================================================
    # Ability splash bar animations
    #=============================================================================
    def pbShowAbilitySplash(battler,ability)
      side = battler.index % 2
      pbHideAbilitySplash(battler) if @sprites["abilityBar_#{side}"].visible
      splashBar = @sprites["abilityBar_#{side}"]
      splashBar.battler = battler
      splashBar.ability = ability
      abilitySplashAnim = AbilitySplashAppearAnimation.new(@sprites,@viewport,side)
      loop do
        abilitySplashAnim.update
        pbUpdate
        break if abilitySplashAnim.animDone?
      end
      abilitySplashAnim.dispose
    end
  
    def pbHideAbilitySplash(battler)
      return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      side = battler.index%2
      return if !@sprites["abilityBar_#{side}"].visible
      abilitySplashAnim = AbilitySplashDisappearAnimation.new(@sprites,@viewport,side)
      loop do
        abilitySplashAnim.update
        pbUpdate
        break if abilitySplashAnim.animDone?
      end
      abilitySplashAnim.dispose
    end
  
    def pbReplaceAbilitySplash(battler)
      return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      pbShowAbilitySplash(battler)
    end

    #=============================================================================
    # Tribe splash bar animations
    #=============================================================================
    def pbShowTribeSplash(side,tribeName,trainerName = nil)
      if side.is_a?(PokeBattle_Battler)
        trainerName = side.owner.name unless trainerName
        sideIndex = side.index % 2
      elsif side.is_a?(PokeBattle_ActiveSide)
        sideIndex = side.index
      else
        sideIndex = side
      end
      pbHideTribeSplash(sideIndex) if @sprites["tribeBar_#{sideIndex}"].visible
      @sprites["tribeBar_#{sideIndex}"].tribeName = tribeName
      @sprites["tribeBar_#{sideIndex}"].trainerName = trainerName
      abilitySplashAnim = TribeSplashAppearAnimation.new(@sprites,@viewport,sideIndex)
      loop do
        abilitySplashAnim.update
        pbUpdate
        break if abilitySplashAnim.animDone?
      end
      abilitySplashAnim.dispose
    end

    def pbHideTribeSplash(side)
      sideIndex = side.index % 2 if side.is_a?(PokeBattle_Battler)
      sideIndex = side.index if side.is_a?(PokeBattle_ActiveSide)
      return unless @sprites["tribeBar_#{sideIndex}"].visible
      abilitySplashAnim = TribeSplashDisappearAnimation.new(@sprites,@viewport,sideIndex)
      loop do
        abilitySplashAnim.update
        pbUpdate
        break if abilitySplashAnim.animDone?
      end
      abilitySplashAnim.dispose
    end
  
    #=============================================================================
    # HP change animations
    #=============================================================================
    # Shows a HP-changing common animation and animates a data box's HP bar.
    # Called by def pbReduceHP, def pbRecoverHP.
    def pbHPChanged(battler,oldHP,showAnim=false)
      @briefMessage = false
      if battler.hp>oldHP
        pbCommonAnimation("HealthUp",battler) if showAnim && @battle.showAnims
      elsif battler.hp<oldHP
        pbCommonAnimation("HealthDown",battler) if showAnim && @battle.showAnims
      end
      @sprites["dataBox_#{battler.index}"].animateHP(oldHP,battler.hp,battler.totalhp)
      while @sprites["dataBox_#{battler.index}"].animatingHP
        pbUpdate
      end
    end
  
    def pbDamageAnimation(battler,effectiveness=0,fastAnimation=false)
      return if @battle.autoTesting
      @briefMessage = false
      # Damage animation
      damageAnim = BattlerDamageAnimation.new(@sprites,@viewport,battler.index,effectiveness,battler,fastAnimation)
      loop do
        damageAnim.update
        pbUpdate
        break if damageAnim.animDone?
      end
      damageAnim.dispose
    end
  
    # Animates battlers flashing and data boxes' HP bars because of damage taken
    # by an attack. targets is an array, which are all animated simultaneously.
    # Each element in targets is also an array: [battler, old HP, effectiveness]
    def pbHitAndHPLossAnimation(targets,fastHitAnimation=false)
      @briefMessage = false
      # Set up animations
      damageAnims = []
      targets.each do |t|
          anim = BattlerDamageAnimation.new(@sprites,@viewport,t[0].index,t[2],t[0],fastHitAnimation)
          damageAnims.push(anim)
          @sprites["dataBox_#{t[0].index}"].animateHP(t[1],t[0].hp,t[0].totalhp,fastHitAnimation)
      end
      # Update loop
      loop do
      damageAnims.each { |a| a.update }
      pbUpdate
      allDone = true
      targets.each do |t|
          next if !@sprites["dataBox_#{t[0].index}"].animatingHP
          allDone = false
          break
      end
      next if !allDone
      damageAnims.each do |a|
          next if a.animDone?
          allDone = false
          break
      end
      next if !allDone
      break
      end
      damageAnims.each { |a| a.dispose }
  end
  
    #=============================================================================
    # Animates a data box's Exp bar
    #=============================================================================
    def pbEXPBar(battler,startExp,endExp,tempExp1,tempExp2)
      return if !battler
      startExpLevel = tempExp1-startExp
      endExpLevel   = tempExp2-startExp
      expRange      = endExp-startExp
      dataBox = @sprites["dataBox_#{battler.index}"]
      dataBox.animateExp(startExpLevel,endExpLevel,expRange)
      while dataBox.animatingExp; pbUpdate; end
    end
  
    #=============================================================================
    # Shows stats windows upon a Pokémon levelling up
    #=============================================================================
    def pbLevelUp(pkmn,_battler,oldTotalHP,oldAttack,oldDefense,oldSpAtk,oldSpDef,oldSpeed)
      pbTopRightWindow(
         _INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
         pkmn.totalhp-oldTotalHP,pkmn.attack-oldAttack,pkmn.defense-oldDefense,
         pkmn.spatk-oldSpAtk,pkmn.spdef-oldSpDef,pkmn.speed-oldSpeed))
      pbTopRightWindow(
         _INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
         pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed))
    end
  
    #=============================================================================
    # Animates a Pokémon fainting
    #=============================================================================
    def pbFaintBattler(battler)
      @briefMessage = false
      # Pokémon plays cry and drops down, data box disappears
      faintAnim   = BattlerFaintAnimation.new(@sprites,@viewport,battler.index,@battle)
      dataBoxAnim = DataBoxDisappearAnimation.new(@sprites,@viewport,battler.index)
      loop do
        faintAnim.update
        dataBoxAnim.update
        pbUpdate
        break if faintAnim.animDone? && dataBoxAnim.animDone?
      end
      faintAnim.dispose
      dataBoxAnim.dispose
    end
  
    #=============================================================================
    # Animates throwing a Poké Ball at a Pokémon in an attempt to catch it
    #=============================================================================
    def pbThrow(ball,shakes,critical,targetBattler,showPlayer=false,velocityMult = 1.0)
      @briefMessage = false
      captureAnim = PokeballThrowCaptureAnimation.new(@sprites,@viewport,
        ball,shakes,critical,@battle.battlers[targetBattler],showPlayer,velocityMult)
      loop do
        captureAnim.update
        pbUpdate
        break if captureAnim.animDone? && !inPartyAnimation?
      end
      captureAnim.dispose
    end
  
    def pbThrowSuccess
      return if @battle.opponent
      @briefMessage = false
      pbMEPlay(pbGetWildCaptureME)
      i = 0
      loop do
        pbUpdate
        break if i>=Graphics.frame_rate*3.5   # 3.5 seconds
        i += 1
      end
      pbMEStop
      pbWildBattleSuccess if @battle.is_a?(PokeBattle_SafariZone)
    end
  
    def pbHideCaptureBall(idxBattler)
      # NOTE: It's not really worth writing a whole PokeBattle_Animation class for
      #       making the capture ball fade out.
      ball = @sprites["captureBall"]
      return if !ball
      # Data box disappear animation
      dataBoxAnim = DataBoxDisappearAnimation.new(@sprites,@viewport,idxBattler)
      loop do
        dataBoxAnim.update
        ball.opacity -= 12*20/Graphics.frame_rate if ball.opacity>0
        pbUpdate
        break if dataBoxAnim.animDone? && ball.opacity<=0
      end
      dataBoxAnim.dispose
    end
  
    def pbThrowAndDeflect(ball,idxBattler)
      @briefMessage = false
      throwAnim = PokeballThrowDeflectAnimation.new(@sprites,@viewport,
         ball,@battle.battlers[idxBattler])
      loop do
        throwAnim.update
        pbUpdate
        break if throwAnim.animDone?
      end
      throwAnim.dispose
    end
  
    #=============================================================================
    # Hides all battler shadows before yielding to a move animation, and then
    # restores the shadows afterwards
    #=============================================================================
    def pbSaveShadows
      # Remember which shadows were visible
      shadows = Array.new(@battle.battlers.length) do |i|
        shadow = @sprites["shadow_#{i}"]
        ret = (shadow) ? shadow.visible : false
        shadow.visible = false if shadow
        next ret
      end
      # Yield to other code, i.e. playing an animation
      yield
      # Restore shadow visibility
      for i in 0...@battle.battlers.length
        shadow = @sprites["shadow_#{i}"]
        shadow.visible = shadows[i] if shadow
      end
    end
  
    #=============================================================================
    # Loads a move/common animation
    #=============================================================================
    # Returns the animation ID to use for a given move/user. Returns nil if that
    # move has no animations defined for it.
    def self.pbFindMoveAnimDetails(move2anim,moveID,idxUser,hitNum=0)
      move_data = GameData::Move.get(moveID)
      id_number = move_data.id_number
      noFlip = false
      if (idxUser&1)==0   # On player's side
        anim = move2anim[0][id_number]
      else                # On opposing side
        anim = move2anim[1][id_number]
        noFlip = true if !anim.nil?
        anim = move2anim[0][id_number] if anim.nil?
      end
      return [anim+hitNum,noFlip] if !anim.nil?
      # The move may be assigned to use the animation from another
      if !move_data.animation_move.nil?
        otherMoveAnim = self.pbFindMoveAnimDetails(move2anim,move_data.animation_move,idxUser,hitNum)
        return otherMoveAnim if !otherMoveAnim.nil?
      end
      return nil
    end
  
    # Returns the animation ID to use for a given move. If the move has no
    # animations, tries to use a default move animation depending on the move's
    # type. If that default move animation doesn't exist, trues to use Tackle's
    # move animation. Returns nil if it can't find any of these animations to use.
    def self.pbFindMoveAnimation(moveID, idxUser, hitNum)
      begin
        move2anim = pbLoadMoveToAnim
        # Find actual animation requested (an opponent using the animation first
        # looks for an OppMove version then a Move version)
        anim = self.pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum)
        return anim if anim
        # Actual animation not found, get the default animation for the move's type
        moveData = GameData::Move.get(moveID)
        target_data = GameData::Target.get(moveData.target)
        moveType = moveData.type
        moveKind = moveData.category
        moveKind += 3 if target_data.num_targets > 1 || target_data.affects_foe_side
        moveKind += 3 if moveKind == 2 && target_data.num_targets > 0
        # [one target physical, one target special, user status,
        #  multiple targets physical, multiple targets special, non-user status]
        typeDefaultAnim = {
          :NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,     :SWIFT,          :TAILWHIP],
          :FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,            nil,             nil],
          :FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,            :AIRCUTTER,      :FEATHERDANCE],
          :POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,            :ACID,           :POISONPOWDER],
          :GROUND   => [:SANDTOMB,     :MUDSLAP,      :SHOREUP,     :EARTHQUAKE,    :EARTHPOWER,     :MUDSPORT],
          :ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,     :ANCIENTPOWER,   :SANDSTORM],
          :BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,            :STRUGGLEBUG,    :STRINGSHOT],
          :GHOST    => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,            nil,             :CONFUSERAY],
          :STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,            nil,             :METALSOUND],
          :FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,            :INCINERATE,     :WILLOWISP],
          :WATER    => [:CRABHAMMER,   :WATERPULSE,   :AQUARING,    nil,            :SURF,           :WATERSPORT],
          :GRASS    => [:VINEWHIP,     :ENERGYBALL,   :COTTONGUARD, :RAZORLEAF,     nil,             :SPORE],
          :ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,            :DISCHARGE,      :THUNDERWAVE],
          :PSYCHIC  => [:PSYCHOCUT,    :CONFUSION,    :CALMMIND,    nil,            :SYNCHRONOISE,   :MIRACLEEYE],
          :ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,            :POWDERSNOW,     :HAIL],
          :DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, :BREAKINGSWIPE, :TWISTER,        nil],
          :DARK     => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   :BRUTALSWING,   :SNARL,          :EMBARGO],
          :FAIRY    => [:PLAYROUGH,    :FAIRYWIND,    :POUT,        nil,            :DAZZLINGGLEAM,  :SWEETKISS]
        }
        if typeDefaultAnim[moveType]
          anims = typeDefaultAnim[moveType]
          #The the most correct possible animation
          if GameData::Move.exists?(anims[moveKind])
            anim = self.pbFindMoveAnimDetails(move2anim, anims[moveKind], idxUser)
          end
          #If the move is multitarget, but no such animation exists, try for the single target version
          if !anim && moveKind >= 3 && GameData::Move.exists?(anims[moveKind - 3])
            anim = self.pbFindMoveAnimDetails(move2anim, anims[moveKind - 3], idxUser)
          end
          # If not even the single target version exists, try the "user status" animatio
          if !anim && GameData::Move.exists?(anims[2])
            anim = self.pbFindMoveAnimDetails(move2anim, anims[2], idxUser)
          end
          # If not even the "user status" exists, fall back on the normal type
          if !anim
            anim = self.pbFindMoveAnimDetails(move2anim,typeDefaultAnim[:NORMAL][moveKind],idxUser)
          end
        end
        return anim if anim
      
        # Default animation for the move's type not found, use Tackle's animation
        if moveData.category != 2 && GameData::Move.exists?(:TACKLE)
          return self.pbFindMoveAnimDetails(move2anim, :TACKLE, idxUser)
        end
      rescue
      end
      return nil
    end
  
    #=============================================================================
    # Plays a move/common animation
    #=============================================================================
    def pbAnimation(moveID,user,targets,hitNum=0)
      animID = PokeBattle_Scene.pbFindMoveAnimation(moveID,user.index,hitNum)
      return if !animID
      anim = animID[0]
      target = (targets && targets.is_a?(Array)) ? targets[0] : targets
      animations = pbLoadBattleAnimations
      return if !animations
      speedMult = getBattleAnimationSpeedMult
      pbSaveShadows {
        if animID[1]   # On opposing side and using OppMove animation
          pbAnimationCore(animations[anim],target,user,true,speedMult)
        else           # On player's side, and/or using Move animation
          pbAnimationCore(animations[anim],user,target,false,speedMult)
        end
      }
    end
  
    # Plays a common animation.
    def pbCommonAnimation(animName,user=nil,target=nil)
      return if nil_or_empty?(animName)
      target = target[0] if target && target.is_a?(Array)
      animations = pbLoadBattleAnimations
      return if !animations
      speedMult = getBattleAnimationSpeedMult
      animations.each do |a|
        next if !a || a.name!="Common:"+animName
        pbAnimationCore(a,user,(target!=nil) ? target : user,false,speedMult)
        return
      end
    end
  
    def pbAnimationCore(animation,user,target,oppMove=false,speedMult=1)
      return if !animation

      # Pretend user or target aren't there under some circumstances
      user = nil if user&.dummy?
      target = nil if target&.dummy?

      @briefMessage = false
      userSprite   = user ? @sprites["pokemon_#{user.index}"] : nil
      targetSprite = target ? @sprites["pokemon_#{target.index}"] : nil
      # Remember the original positions of Pokémon sprites
      oldUserX = (userSprite) ? userSprite.x : 0
      oldUserY = (userSprite) ? userSprite.y : 0
      oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
      oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
      # Create the animation player
      animPlayer = PBAnimationPlayerX.new(animation,user,target,self,oppMove,false,speedMult)
      # Apply a transformation to the animation based on where the user and target
      # actually are. Get the centres of each sprite.
      userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
      if targetSprite
        targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
      else
        targetHeight = userHeight
      end
      animPlayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         oldUserX,oldUserY-userHeight/2,
         oldTargetX,oldTargetY-targetHeight/2)
      # Play the animation
      animPlayer.start
      loop do
        animPlayer.update
        pbUpdate
        break if animPlayer.animDone?
      end
      animPlayer.dispose
      # Return Pokémon sprites to their original positions
      if userSprite
        userSprite.x = oldUserX
        userSprite.y = oldUserY
        userSprite.pbSetOrigin
      end
      if targetSprite
        targetSprite.x = oldTargetX
        targetSprite.y = oldTargetY
        targetSprite.pbSetOrigin
      end
    end
end

def getBattleAnimationSpeedMult
    return [1,2,1][$Options.battlescene || 0]
end