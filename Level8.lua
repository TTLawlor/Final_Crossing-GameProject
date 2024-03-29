
local composer = require( "composer" )
-- local physics = require( "physics" )
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
local livesCount = composer.getVariable( "livesCount")
local livesText
local feathersText
local featherCount = composer.getVariable( "featherCount")
local gunText
local characterJumping = 0
local keyPressed = 0
local died = false
local paused = false
local turnCount = 0
local gun = false
local backgroundMusic = audio.loadStream( "relaxing.wav" )
local walkSound = audio.loadSound( "walk.mp3" )
local featherSound = audio.loadSound( "feather.mp3" )
local heartSound = audio.loadSound( "heart.mp3" )
local batterySound = audio.loadSound( "battery.mp3" )
local audioLevel
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

local mapData
local map
local character
local feathers
local lives

local function updateText()
    livesText.text = "x " .. livesCount
end

function scene:resumeGame()
    -- Code to resume game
    audioLevel = composer.getVariable( "audioLevel" )
    audio.resume()
    keyPressed = 0
    physics.start()
end


local function pauseScreen(event)
  if (event.phase == "down" and keyPressed == 0) then
      if (event.keyName == "escape") then
        -- audio.pause()
        composer.setVariable( "audioLevel", audioLevel )
        keyPressed = 1
        physics.pause()
        composer.showOverlay( "pause", {isModal=true, effect="slideDown"}  )
      end
  end
end

local function gotoDeathScreen()
    audio.pause()
    -- character:pause()
    physics.pause()
    composer.setVariable( "livesCount", livesCount )
    composer.setVariable( "featherCount", featherCount )
    composer.gotoScene("gameOver", { time=700, effect="slideLeft" })
end

local function gotoLevel9(self, event)
    if(event.other.myName == "exit" or event.other.myName == "character") then
      if(event.phase == "began") then
        composer.setVariable( "livesCount", livesCount )
        composer.setVariable( "featherCount", featherCount )
        composer.setVariable( "nextScene", "Level9" )
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
      elseif(upPressed and leftPressed and characterJumping < 2) then
          -- rightPressed = false
          leftPressed = true
              character:applyLinearImpulse( -10, -60, character.x, character.y )
              characterJumping = characterJumping + 1
        elseif(upPressed and rightPressed and characterJumping < 2) then
          rightPressed = true
          -- leftPressed = true
              character:applyLinearImpulse( 10, -60, character.x, character.y )
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
    character.y = display.contentCenterY + 250
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

local function triggerCollisionDeath(self, event)
  if(event.other.myName == "character") then
     if(event.phase == "began") then
       if( died == false ) then
         died = true
           if( livesCount > 1 )then
             livesCount = livesCount - 1
             livesText.text = "x" .. livesCount
             character.alpha = 0
             timer.performWithDelay( 100, restoreChar )
           elseif( livesCount == 1 )then
             livesCount = livesCount - 1
             -- character.alpha = 0
             character:removeSelf()
             character = nil
             timer.performWithDelay( 50, gotoDeathScreen )
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
					feathersText.text = "x" .. featherCount
          display.remove(feather)
          feather = nil
        end
      end
end


local function triggerCollisionHeart(self, event)
      if(event.other.myName == "heart" or event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( heartSound, { channel=3} )
					livesCount = livesCount + 1
					livesText.text = "x" .. livesCount
          display.remove(heart)
          heart = nil
        end
      end
end

local function fireGun(event)

if gun==true then
   if( event.keyName == "space" and characterJumping == 0 ) then
      if (event.phase == "down") then
     transition.fadeOut( gunText, { time=1000, y=gunText.y+200, transition=easing.linear } )
     local gunLaser = display.newImageRect("laser.png", 10, 10 ) --this is laser size
     physics.addBody( gunLaser, "dynamic", {isSensor=true} )
     gunLaser.myName = "gunlaser"
     gunLaser.gravityScale = 0

     gunLaser.x = character.x
     gunLaser.y = character.y
   if(turnCount == 0)then
     transition.to( gunLaser, { x=4000, time=1500,  -- x is lasers destination, time is how fast it goes
     onComplete = function() display.remove( gunLaser ) end
     } )
   elseif(turnCount == 1)then
      transition.to( gunLaser, { x=-2000, time=1500,  -- x is lasers destination, time is how fast it goes
      onComplete = function() display.remove( gunLaser ) end
      } )
    end
     end
    end
  end
end

  local function gunCollision( event )
     if( event.phase == "began" ) then
   local obj1 = event.object1
   local obj2 = event.object2
   if( obj1.myName == "character" and obj2.myName == "gun" )then
       collectablesChannel =  audio.play( batterySound, { channel=3} )
       gunText = display.newText("press SPACE to shoot", 1000, 300, native.systemFont, 60 )
       gun=true
       event.object2:removeSelf()
    elseif ( obj1.myName == "gun" and obj2.myName == "character" )then
       collectablesChannel =  audio.play( batterySound, { channel=3} )
       gunText = display.newText("press SPACE to shoot", 1000, 300, native.systemFont, 60 )
       gun=true
       event.object1:removeSelf()
     end
   end
  end

 local function gunlaserCollision( event )
    if( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2
          if ( obj1.myName == "goose" and obj2.myName == "gunlaser") then
              event.object1:removeSelf()

          elseif( obj1.myName == "gunlaser" and obj2.myName == "goose" ) then
              event.object2:removeSelf()
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

local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1} )
audioLevel = audio.setVolume( 0.03, { channel=1 } )
audio.setVolume( 0.05, { channel=2 } )
audio.setVolume( 0.07, { channel=3 } )
audio.setVolume( 0.07, { channel=4 } )

  mapData = require "objects.Screen8" -- load from lua export
  map = tiled.new(mapData, "objects")

  sheetOptions =
  {
      width = 108,
      height = 200,
      numFrames = 9
  }

  walkCharacter = graphics.newImageSheet( "9Walkies.png", sheetOptions )

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
  character.y = display.contentCenterY + 250
  smallRect = {39,-43, 39,54, -25,54, -25,-43}
  physics.addBody( character, "dynamic", { density=1.0, bounce=0.0, friction =0.5, shape = smallRect})
  character.isFixedRotation = true


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

  spikes8 = map:findObject("spikes8")
  spikes8.myName = "spikes8"
  spikes8.collision = triggerCollisionDeath

  spikes9 = map:findObject("spikes9")
  spikes9.myName = "spikes9"
  spikes9.collision = triggerCollisionDeath

  spikes10 = map:findObject("spikes10")
  spikes10.myName = "spikes10"
  spikes10.collision = triggerCollisionDeath

  spikes11 = map:findObject("spikes11")
  spikes11.myName = "spikes11"
  spikes11.collision = triggerCollisionDeath

  spikes12 = map:findObject("spikes12")
  spikes12.myName = "spikes12"
  spikes12.collision = triggerCollisionDeath

  spikes13 = map:findObject("spikes13")
  spikes13.myName = "spikes1"
  spikes13.collision = triggerCollisionDeath

  feather = map:findObject("feather")
  feather.myName = "feather"
  feather.collision = triggerCollisionFeather

  heart = map:findObject("heart")
  heart.myName = "heart"
  heart.collision = triggerCollisionHeart

  gun = map:findObject("gun")
  gun.myName = "gun"

  exit = map:findObject("exit")
  exit.myName = "exit"

  exit.collision = gotoLevel9

	lives = display.newImageRect("heart.png",45,45)
	lives.x = display.contentCenterX-900
	lives.y = display.contentCenterY-500

	livesText = display.newText("x" .. livesCount, 120, 35, native.systemFont, 40 )
	livesText:setFillColor( 1, 1, 1 )

	feathers = display.newImageRect("feather.png",45,45)
	feathers.x = display.contentCenterX-900
	feathers.y = display.contentCenterY-440

	feathersText = display.newText("x" .. featherCount, 120, 100, native.systemFont, 40 )
	feathersText:setFillColor( 1, 1, 1 )

  spikes1:addEventListener("collision")
  spikes2:addEventListener("collision")
  spikes3:addEventListener("collision")
  spikes4:addEventListener("collision")
  spikes5:addEventListener("collision")
  spikes6:addEventListener("collision")
  spikes7:addEventListener("collision")
  spikes8:addEventListener("collision")
  spikes9:addEventListener("collision")
  spikes10:addEventListener("collision")
  spikes11:addEventListener("collision")
  spikes12:addEventListener("collision")
  spikes13:addEventListener("collision")
  feather:addEventListener( "collision")
  heart:addEventListener( "collision" )
  exit:addEventListener( "collision" )

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
    Runtime:addEventListener( "key", fireGun )
    Runtime:addEventListener( "collision", gunCollision )
    Runtime:addEventListener( "collision", gunlaserCollision )
    Runtime:addEventListener("key", invis)


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

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		-- character:removeEventListener( "collision" )
    display.remove(gunText)
    Runtime:removeEventListener( "key", pauseScreen)
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener( "key", fireGun )
    Runtime:removeEventListener( "collision", gunCollision )
    Runtime:removeEventListener( "collision", gunlaserCollision )
    Runtime:removeEventListener("key", invis)
		physics.pause()
		composer.removeScene( "Level8" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  -- character:removeSelf()
  -- character = nil

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
