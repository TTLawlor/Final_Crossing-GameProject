
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local tiled = require "com.ponywolf.ponytiled"
local physics = require( "physics" )

physics.start()
physics.setGravity(0, 30)
-- physics.setDrawMode( "hybrid" )



-- map.x,map.y = display.contentCenterX - map.designedWidth/2, display.contentCenterY - map.designedHeight/2

--Declare variables
local backGroup
local bulletGroup
local livesCount = composer.getVariable( "livesCount")
local livesText
local feathersText
local batteryCount = 0
local featherCount = composer.getVariable( "featherCount")
local characterJumping = 0
local turnCount = 0
local keyPressed = 0
local died = false
local paused = false
local backgroundMusic = audio.loadStream( "finalLevels.mp3" )
local walkSound = audio.loadSound( "walk.mp3" )
local featherSound = audio.loadSound( "feather.mp3" )
local heartSound = audio.loadSound( "heart.mp3" )
local batterySound = audio.loadSound( "battery.mp3" )
local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1} )
audio.setVolume( 0.03, { channel=1 } )
audio.setVolume( 0.05, { channel=2 } )
audio.setVolume( 0.07, { channel=3 } )

local walkChannel
local collectablesChannel
local nextScene
local sheetOptions
local walkCharacter
local walking


local upPressed = false
local downPressed = false
local leftPressed = false
local rightPressed = false

local exit1
local spikes1
local spikes2
local spikes3
local spikes4
local spikes5
local spikes6
local spikes7
local turret1
local turret2
local turret3
local turret4
local turret5
local turret6
local turret8
local turret9
local turret10
local turret11
local turret12
local turret13
local turret14
local laser
local laser1
local laser2
local laser3
local laser4
local laser5
local laser6
local laser7
local laser8
local laser9
local laser10
local laser11
local laser12
local laser13
local laser14
local ground
local ground1
local ground2
local ground3
local ground4
local ground5
local ground6
local platform1
local platform2
local platform3
local platform4
local platform5
local platform6
local platform7
local platform8
local mapData
local map
local character
local feathers
local lives
local turretShoot


local function updateText()
    livesText.text = "x " .. livesCount
end

function scene:resumeGame()
    -- Code to resume game
    paused = false
    laser1.isVisible = true
    laser2.isVisible = true
    laser3.isVisible = true
    laser4.isVisible = true
    laser5.isVisible = true
    laser6.isVisible = true
    laser7.isVisible = true
    laser8.isVisible = true
    laser9.isVisible = true
    laser10.isVisible = true
    laser11.isVisible = true
    laser12.isVisible = true
    laser13.isVisible = true
    laser14.isVisible = true
    timer.resume(turretShoot)
    audio.resume()
    keyPressed = 0
    physics.start()
end


local function pauseScreen(event)
  if (event.phase == "down" and keyPressed == 0) then
      if (event.keyName == "escape") then
        paused = true
        laser1.isVisible = false
        laser2.isVisible = false
        laser3.isVisible = false
        laser4.isVisible = false
        laser5.isVisible = false
        laser6.isVisible = false
        laser7.isVisible = false
        laser8.isVisible = false
        laser9.isVisible = false
        laser10.isVisible = false
        laser11.isVisible = false
        laser12.isVisible = false
        laser13.isVisible = false
        laser14.isVisible = false
        timer.pause(turretShoot)
        audio.pause()
        keyPressed = 1
        physics.pause()
        composer.showOverlay( "pause", {isModal=true, effect="slideDown"}  )
      end
  end
end

local function gotoDeathScreen()
    audio.pause()
    composer.setVariable( "livesCount", livesCount )
    composer.setVariable( "featherCount", featherCount )
    composer.gotoScene("gameOver", { time=1000, effect="slideLeft" })
end

local function gotoLevel14(self, event)
    if(event.other.myName == "exit" or event.other.myName == "character") then
      if(event.phase == "began") then
        composer.setVariable( "livesCount", livesCount )
        composer.setVariable( "featherCount", featherCount )
        composer.setVariable( "nextScene", "Level14" )
        composer.gotoScene("loading", { time=20, effect="slideLeft" })
    end
  end
end

    local function key( event)
      if(paused == false) then
        if (event.phase == "down") then
            if (event.keyName == "w") then
                upPressed = true
            elseif (event.keyName == "s") then
                downPressed = true
            elseif (event.keyName == "a") then
              if(turnCount == 1)then
                character:setSequence( "walk" )
                character:scale(1,1)
                character:play()
                turnCount = 1
              elseif(turnCount == 0)then
                character:setSequence( "walk" )
                character:scale(-1,1)
                character:play()
                turnCount = 1
              end
                leftPressed = true
            elseif (event.keyName == "d") then
              if(turnCount == 1)then
                character:setSequence( "walk" )
                character:scale(-1,1)
                character:play()
                turnCount = 0
              elseif(turnCount == 0)then
                character:setSequence( "walk" )
                character:scale(1,1)
                character:play()
                turnCount = 0
              end
                rightPressed = true
            end
        elseif (event.phase == "up") then
            if (event.keyName == "w") then
                upPressed = false
            elseif (event.keyName == "s") then
                downPressed = false
            elseif (event.keyName == "a") then
                audio.stop(2)
                leftPressed = false
            elseif (event.keyName == "d") then
                audio.stop(2)
                rightPressed = false
            end
            character:setSequence( "idle" )
            character:scale(1,1)
            character:play()
        end
      end
    end

local function jump(event)
  if(upPressed and characterJumping < 2) then
        character:applyLinearImpulse( 0, -80, character.x, character.y )
        characterJumping = characterJumping + 1
  end
  local function onCollision( self, event )
      if ( event.phase == "began" ) then
          characterJumping = 0
          character:setLinearVelocity( 0, 0 )
      end
  end
      character.collision = onCollision
      character:addEventListener( "collision" )
end

local function invis(event)
  if (downPressed) then
    leftPressed = false
    rightPressed = false
    upPressed = false
    character.isBodyActive = false
    character.alpha = 0.5
  else
    character.alpha = 1
    character.isBodyActive = true

  end
end

local function enterFrame(event)
    if (leftPressed) then
       walkChannel =  audio.play( walkSound, { channel=2} )
       character.x = character.x - 8
    end
    if (rightPressed) then
        walkChannel = audio.play( walkSound, { channel=2} )
        character.x = character.x + 8
    end
end

local function spawn()
  if(spawnPoint == false) then
    character.x = display.contentCenterX + 750
    character.y = display.contentCenterY - 370
  else
    character.x = display.contentCenterX - 800
    character.y = display.contentCenterY - 150
  end
end

-- After loss of life
local function restoreChar()

    character.isBodyActive = false
    spawn()

-- Fade in the character
    transition.to( character, { alpha=1, time=100, onComplete = function()
        character.isBodyActive = true
            died = false
        end
    } )
end

local function fireTurret()

      laser1 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser1 )
      physics.addBody( laser1, "static")
      laser1.gravityScale = 0
      laser1.isBullet = applyTorque

      laser2 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser2 )
      physics.addBody( laser2,  "static")
      laser2.gravityScale = 0
      laser2.isBullet = applyTorque

      laser3 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser3 )
      physics.addBody( laser3,  "static")
      laser3.gravityScale = 0
      laser3.isBullet = applyTorque

      laser4 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser4 )
      physics.addBody( laser4,  "static")
      laser4.gravityScale = 0
      laser4.isBullet = applyTorque

      laser5 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser5 )
      physics.addBody( laser5,  "static")
      laser5.gravityScale = 0
      laser5.isBullet = applyTorque

      laser6 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser6 )
      physics.addBody( laser6,  "static")
      laser6.gravityScale = 0
      laser6.isBullet = applyTorque

      -- laser7 = display.newImageRect("laser.png", 20, 10 )
      -- bulletGroup:insert( laser7 )
      -- physics.addBody( laser7,  "static")
      -- laser7.gravityScale = 0
      -- laser7.isBullet = applyTorque

      laser8 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser8 )
      physics.addBody( laser8,  "static")
      laser8.gravityScale = 0
      laser8.isBullet = applyTorque

      laser9 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser9 )
      physics.addBody( laser9,  "static")
      laser9.gravityScale = 0
      laser9.isBullet = applyTorque

      laser10 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser10 )
      physics.addBody( laser10,  "static")
      laser10.gravityScale = 0
      laser10.isBullet = applyTorque

      laser11 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser11 )
      physics.addBody( laser11,  "static")
      laser11.gravityScale = 0
      laser11.isBullet = applyTorque

      laser12 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser12 )
      physics.addBody( laser12, "static")
      laser12.gravityScale = 0
      laser12.isBullet = applyTorque

      laser13 = display.newImageRect("laser.png", 10, 10 )
      bulletGroup:insert( laser13 )
      physics.addBody( laser13,  "static")
      laser13.gravityScale = 0
      laser13.isBullet = applyTorque

      laser14 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser14 )
      physics.addBody( laser14, "static")
      laser14.gravityScale = 0
      laser14.isBullet = applyTorque

      laser1.x = turret1.x
      laser1.y = turret1.y
      laser2.x = turret2.x
      laser2.y = turret2.y
      laser3.x = turret3.x
      laser3.y = turret3.y
      laser4.x = turret4.x
      laser4.y = turret4.y
      laser5.x = turret5.x
      laser5.y = turret5.y
      laser6.x = turret6.x
      laser6.y = turret6.y
      -- laser7.x = turret7.x
      -- laser7.y = turret7.y
      laser8.x = turret8.x
      laser8.y = turret8.y
      laser9.x = turret9.x
      laser9.y = turret9.y
      laser10.x = turret10.x
      laser10.y = turret10.y
      laser11.x = turret11.x
      laser11.y = turret11.y
      laser12.x = turret12.x
      laser12.y = turret12.y
      laser13.x = turret13.x
      laser13.y = turret13.y
      laser14.x = turret14.x
      laser14.y = turret14.y

      transition.to( laser1, { y=1055, time=1000, onComplete = function() display.remove( laser1 ) end} )
      transition.to( laser2, { x=1600, time=600, onComplete = function() display.remove( laser2 ) end} )
      transition.to( laser3, { x=1890, time=600, onComplete = function() display.remove( laser3 ) end} )
      transition.to( laser4,  {x=1890, time=600, onComplete = function() display.remove( laser4 ) end} )
      transition.to( laser5,  { x=1890, time=600, onComplete = function() display.remove( laser5 ) end} )
      transition.to( laser6,  { y=20, time=1000, onComplete = function() display.remove( laser6 ) end} )
      -- transition.to( laser7,  { x=20, time=1400, onComplete = function() display.remove( laser7 ) end} )
      transition.to( laser8,  { y=1055, time=1000, onComplete = function() display.remove( laser8 ) end} )
      transition.to( laser9,  { y=445, time=700, onComplete = function() display.remove( laser9 ) end} )
      transition.to( laser10,  { x=1250, time=1000, onComplete = function() display.remove( laser10 ) end} )
      transition.to( laser11,  { y=225, time=400, onComplete = function() display.remove( laser11 ) end} )
      transition.to( laser12,  { x=450, time=1000, onComplete = function() display.remove( laser12 ) end} )
      transition.to( laser13,  { x=350, y=850, time=1000, onComplete = function() display.remove( laser13 ) end} )
      transition.to( laser14,  { x=825, time=1000, onComplete = function() display.remove( laser14 ) end} )

      laser1.myName = "laser"
      laser2.myName = "laser"
      laser3.myName = "laser"
      laser4.myName = "laser"
      laser5.myName = "laser"
      laser6.myName = "laser"
      -- laser7.myName = "laser"
      laser8.myName = "laser"
      laser9.myName = "laser"
      laser10.myName = "laser"
      laser11.myName = "laser"
      laser12.myName = "laser"
      laser13.myName = "laser"
      laser14.myName = "laser"

end

local function laserCollision( event )
     if( event.phase == "began" ) then

       local obj1 = event.object1
       local obj2 = event.object2

         if ( obj1.myName == "character" and obj2.myName == "laser") then
                 died = true

                 if( livesCount > 1 )then
                   livesCount = livesCount - 1
                   livesText.text = "x " .. livesCount
                   character.alpha = 0
                   timer.performWithDelay( 100, restoreChar )
                 elseif( livesCount == 1 )then
                   livesCount = livesCount - 1
                   character.alpha = 0
                   timer.performWithDelay( 2000, gotoDeathScreen )
                 end
           elseif( obj1.myName == "laser" and obj2.myName == "character" ) then
               died = true

               if( livesCount > 1 )then
                 livesCount = livesCount - 1
                 livesText.text = "x " .. livesCount
                 character.alpha = 0
                 timer.performWithDelay( 100, restoreChar )
               elseif( livesCount == 1 )then
                 livesCount = livesCount - 1
                 character.alpha = 0
                 timer.performWithDelay( 2000, gotoDeathScreen )
               end
            end
         end
      end

  local function groundCollisionLaser(event)
    if( event.phase == "began" ) then

      local obj1 = event.object1
      local obj2 = event.object2

        if ( obj1.myName == "ground" and obj2.myName == "laser") then
                event.object2:removeSelf()
          elseif( obj1.myName == "laser" and obj2.myName == "ground" ) then
              event.object1:removeSelf()
           end
        end
  end

local function triggerCollisionDeath(self, event)
  if(event.other.myName == "character") then
     if(event.phase == "began") then
       if( died == false ) then
         died = true
           if( livesCount > 1 )then
             livesCount = livesCount - 1
             livesText.text = "x " .. livesCount
             character.alpha = 0
             timer.performWithDelay( 100, restoreChar )
           elseif( livesCount == 1 )then
             livesCount = livesCount - 1
             character.alpha = 0
             timer.performWithDelay( 2000, gotoDeathScreen )
           end
       end
     end
  end
end


local function triggerCollisionFeather(self, event)
      if(event.other.myName == "feather" or event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( featherSound, { channel=3} )
					featherCount = featherCount + 1
					feathersText.text = "x " .. featherCount
          display.remove(feather)
          feather = nil
          -- display.remove(wall1)
          -- wall1 = nil
        end
      end
end


local function triggerCollisionHeart(self, event)
      if(event.other.myName == "heart" or event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( heartSound, { channel=3} )
					livesCount = livesCount + 1
					livesText.text = "x " .. livesCount
          display.remove(heart)
          heart = nil
          -- display.remove(wall2)
          -- wall2 = nil
        end
      end
end

local function spawnCollision( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          spawnPoint = true
        end
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()
  bulletGroup = display.newGroup()

  background = display.newImageRect(sceneGroup, "plain.png", 1920, 1080)
	background.x = display.contentCenterX
	background.y = display.contentCenterY


local sceneGroup = self.view
  mapData = require "objects.Screen4" -- load from lua export
  map = tiled.new(mapData, "objects")

  sheetOptions =
  {
      width = 159,
      height = 202,
      numFrames = 9
  }

  walkCharacter = graphics.newImageSheet( "gunWalkies.png", sheetOptions )

  walking = {
    -- non-consecutive frames sequence
    {
        name = "idle",
        frames={1},
        time = 1000,
        loopCount = 1
    },
    {
        name = "walk",
        start = 1,
        count = 9,
        time = 200,
        loopCount = 0,
        loopDirection = "bounce"
    }
}

  character = display.newSprite (sceneGroup, walkCharacter, walking)
  character.xScale = 79/108
  character.yScale = 107/200
  character.myName = "character"
  character.x = display.contentCenterX - 800
  character.y = display.contentCenterY - 150
  smallRect = {39,-43, 39,54, -25,54, -25,-43}
  physics.addBody( character, "dynamic", { density=1.0, bounce=0.0, friction =0.5, shape = smallRect})
  character.isFixedRotation = true

  platform1= map:findObject("platform1")
  platform1.myName = "platform1"
  transition.to(platform1, { time = 6000, x = (platform1.x + 256), y = (platform1.y - 288), iterations=0, transition = easing.continuousLoop  })
  platform2= map:findObject("platform2")
  platform2.myName = "platform2"
  transition.to(platform2, { time = 3500, x = (platform2.x - 64), y = (platform2.y - 128), iterations=0, transition = easing.continuousLoop  })
  platform3= map:findObject("platform3")
  platform3.myName = "platform3"
  transition.to(platform3, { time = 12000, x = (platform3.x + 992), iterations=0, transition = easing.continuousLoop  })
  platform4= map:findObject("platform4")
  platform4.myName = "platform4"
  transition.to(platform4, { time = 3500, x = (platform4.x - 192), iterations=0, transition = easing.continuousLoop  })
  platform5= map:findObject("platform5")
  platform5.myName = "platform5"
  transition.to(platform5, { time = 3500, x = (platform5.x - 288), iterations=0, transition = easing.continuousLoop  })
  platform6= map:findObject("platform6")
  platform6.myName = "platform6"
  transition.to(platform6, { time = 6000, y = (platform6.y - 448), iterations=0, transition = easing.continuousLoop  })
  platform7= map:findObject("platform7")
  platform7.myName = "platform7"
  transition.to(platform7, { time = 3500, y = (platform7.y - 192), iterations=0, transition = easing.continuousLoop  })
  platform8= map:findObject("platform8")
  platform8.myName = "platform8"
  transition.to(platform8, { time = 7000, y = (platform8.y - 496), iterations=0, transition = easing.continuousLoop  })

  ground1 = map:listTypes("ground1")
  ground1.myName = "ground"
  ground2 = map:listTypes("ground2")
  ground2.myName = "ground"
  ground3 = map:listTypes("ground3")
  ground3.myName = "ground"
  ground4 = map:listTypes("ground4")
  ground4.myName = "ground"
  ground5 = map:listTypes("ground5")
  ground5.myName = "ground"
  ground6 = map:listTypes("ground6")
  ground1.myName = "ground"

  spikes1 = map:findObject("spikes1")
  spikes1.myName = "spikes1"
  spikes1.collision = triggerCollisionDeath

  spikes2 = map:findObject("spikes2")
  spikes2.myName = "spikes2"
  spikes2.collision = triggerCollisionDeath

  spikes3 = map:findObject("spikes3")
  spikes3.myName = "spikes3"
  spikes3.collision = triggerCollisionDeath

  spikes4 = map:findObject("spikes4")
  spikes4.myName = "spikes4"

  spikes4.collision = triggerCollisionDeath

  spikes5 = map:findObject("spikes5")
  spikes5.myName = "spikes5"
  spikes5.collision = triggerCollisionDeath

  spikes6 = map:findObject("spikes6")
  spikes6.myName = "spikes6"
  spikes6.collision = triggerCollisionDeath

  spikes7 = map:findObject("spikes7")
  spikes7.myName = "spikes7"
  spikes7.collision = triggerCollisionDeath

    turret1 = map:findObject("turret1")
    turret1.myName = "turret1"

    turret2 = map:findObject("turret2")
    turret2.myName = "turret2"

    turret3 = map:findObject("turret3")
    turret3.myName = "turret3"

    turret4 = map:findObject("turret4")
    turret4.myName = "turret4"

    turret5 = map:findObject("turret5")
    turret5.myName = "turret5"

    turret6 = map:findObject("turret6")
    turret6.myName = "turret6"

    turret8 = map:findObject("turret8")
    turret8.myName = "turret8"

    turret9 = map:findObject("turret9")
    turret9.myName = "turret9"

    turret10 = map:findObject("turret10")
    turret10.myName = "turret10"

    turret11 = map:findObject("turret11")
    turret11.myName = "turret11"

    turret12 = map:findObject("turret12")
    turret12.myName = "turret12"

    turret13 = map:findObject("turret13")
    turret13.myName = "turret13"

    turret14 = map:findObject("turret14")
    turret14.myName = "turret14"

  feather = map:findObject("feather")
  feather.myName = "feather"

  feather.collision = triggerCollisionFeather

  heart = map:findObject("heart")
  heart.myName = "heart"

  heart.collision = triggerCollisionHeart

  exit1 = map:findObject("exit1")
  exit1.myName = "exit1"

  exit1.collision = gotoLevel14

	lives = display.newImageRect(sceneGroup, "heart.png",45,45)
	lives.x = display.contentCenterX-900
	lives.y = display.contentCenterY-500

	livesText = display.newText("x " .. livesCount, 120, 35, native.systemFont, 40 )
	livesText:setFillColor( 1, 1, 1 )

	feathers = display.newImageRect(sceneGroup, "feather.png",45,45)
	feathers.x = display.contentCenterX-900
	feathers.y = display.contentCenterY-440

	feathersText = display.newText("x " .. featherCount, 120, 100, native.systemFont, 40 )
	feathersText:setFillColor( 1, 1, 1 )

  spikes1:addEventListener("collision")
  spikes2:addEventListener("collision")
  spikes3:addEventListener("collision")
  spikes4:addEventListener("collision")
  spikes5:addEventListener("collision")
  spikes6:addEventListener("collision")
  spikes7:addEventListener("collision")
  feather:addEventListener( "collision")
  heart:addEventListener( "collision" )
  exit1:addEventListener( "collision" )


    sceneGroup:insert( background )
    sceneGroup:insert( map )
    sceneGroup:insert( character )
  	sceneGroup:insert( livesText )
    sceneGroup:insert( feathersText )
  	sceneGroup:insert( lives )
  	sceneGroup:insert( feathers )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		physics.start()
    Runtime:addEventListener( "key", pauseScreen)
    Runtime:addEventListener( "key", key)
    Runtime:addEventListener( "key", jump )
    Runtime:addEventListener( "enterFrame", enterFrame )
    Runtime:addEventListener("key", invis)
    Runtime:addEventListener( "timer", fireTurret )
    Runtime:addEventListener( "collision", groundCollisionLaser )
    Runtime:addEventListener( "collision", laserCollision )
    turretShoot = timer.performWithDelay( 1500  , fireTurret, -1 )


	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel( turretShoot )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    -- character.angularVelocity = 0
    -- character:setLinearVelocity( 0,0 )
    Runtime:removeEventListener( "key", pauseScreen)
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener("key", invis)
    Runtime:removeEventListener( "timer", fireTurret)
    Runtime:removeEventListener( "collision", groundCollisionLaser )
    Runtime:removeEventListener( "collision", laserCollision )
		physics.pause()
		composer.removeScene( "Level4" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
