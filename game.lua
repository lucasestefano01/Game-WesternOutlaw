
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local lives = 3
local score = 0
local died = false
 
local monstersTable = {}
 
local bh
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createMonster()
	newMonster1 = display.newImageRect( mainGroup,"Images/enemy1.png", 65, 40 )
	newMonster1.x = display.contentWidth + 50
 	table.insert( monstersTable, newMonster1 )
    physics.addBody( newMonster1, "dynamic", { radius=40, bounce=0.8 } )
 	newMonster1.myName = "monster1"

 	newMonster2 = display.newImageRect( mainGroup,"Images/enemy2.png", 65, 40 )
 	newMonster2.x = display.contentWidth + 50
 	table.insert( monstersTable, newMonster2 )
    physics.addBody( newMonster2, "dynamic", { radius=40, bounce=0.8 } )
 	newMonster2.myName = "monster2"

 	newMonster3 = display.newImageRect( mainGroup,"Images/enemy3.png", 65, 40 )
 	newMonster3.x = display.contentWidth + 50
 	table.insert( monstersTable, newMonster3 )
    physics.addBody( newMonster3, "dynamic", { radius=40, bounce=0.8 } )
 	newMonster3.myName = "monster3"
	

 	local whereFrom = math.random(3)

 	if ( whereFrom == 1) then
        -- From the right
        newMonster1.x = display.contentWidth + 40
        newMonster1.y = ( math.random(150,230) ) -- posição
        newMonster1:setLinearVelocity( math.random (-120,-90), math.random (2,15)) --trajeto, velocidade
    elseif ( whereFrom == 2 ) then
        --From the right
        newMonster2.x = display.contentWidth + 40
        newMonster2.y =(math.random(150,230) )
        newMonster2:setLinearVelocity(math.random (-120,-90), math.random (2,15) )
    elseif ( whereFrom == 3 ) then
        --From the right
        newMonster3.x = display.contentWidth + 40
        newMonster3.y =(math.random(150,230) )
        newMonster3:setLinearVelocity(math.random (-120,-90), math.random (2,15) )  
	end
end

-- função atirar
local function fireBullet()
    local newBullet = display.newImageRect( mainGroup, "Images/bullet.png", 18, 18 )
    physics.addBody( newBullet, "dynamic", { isSensor=true } )
    media.playEventSound("Sounds/shot.wav")
    newBullet.isBullet = true
    newBullet.myName = "bullet"
    newBullet.x = bh.x 
    newBullet.y = bh.y 
    newBullet:toBack()
    transition.to( newBullet, { x = 14000, y = -30, time=10000, 
    	onComplete = function() display.remove( newBullet ) end
    	} )
  
end
local function dragBh( event )
	local bh = event.target
	local phase = event.phase

 	if ( "began" == phase ) then
        -- Set touch focus on the bh
        display.currentStage:setFocus( bh)
         -- Store initial offset position
        bh.touchOffsetX = event.x - bh.x
        bh.touchOffsetY = event.y - bh.y

    elseif ( "moved" == phase ) then
     	-- Move the bh to the new touch position
       	bh.x = event.x - bh.touchOffsetX
       	bh.y = event.y - bh.touchOffsetY

    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the bh
        display.currentStage:setFocus( nil )   	
	end

	return true  -- Prevents touch propagation to underlying objects
end
 



local function gameLoop()
	 -- Create new asteroid
    createMonster()
     -- Remove asteroids which have drifted off screen
    for i = #monstersTable, 1, -1 do
    	local thisMonster = monstersTable[i]
    	
 
        if ( thisMonster.x < -100 or
             thisMonster.x > display.contentWidth + 100 or
             thisMonster.y < -100 or
             thisMonster.y > display.contentHeight + 100 )
        then
            display.remove( thisMonster )
            table.remove( monstersTable, i )
        end
 	end
end

gameLoopTimer = timer.performWithDelay( 10000000, gameLoop, 700000 )

local function restoreBh()
 
    bh.isBodyActive = false
    bh.x = display.contentCenterX
    bh.y = display.contentHeight - 100
 
    -- Fade in the bh
    transition.to( bh, { alpha=1, time=4000,
        onComplete = function()
            bh.isBodyActive = true
            died = false
        end
    } )
end

local function endGame()
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
    composer.setVariable( "finalScore", score )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "bullet" and obj2.myName == "monster1" ) or
             ( obj1.myName == "monster1" and obj2.myName == "bullet" ) )
        then
        -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #monstersTable, 1, -1 do
                if ( monstersTable[i] == obj1 or monstersTable[i] == obj2 ) then
                    table.remove( monstersTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = " " .. score
            media.playEventSound("Sounds/coin.wav")

            elseif ( ( obj1.myName == "bh" and obj2.myName == "monster1" ) or
                 ( obj1.myName == "monster1" and obj2.myName == "bh" ) )
        	then
        		if ( died == false ) then
        			 died = true

        			 -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives
                if ( lives == 0 ) then
                    display.remove( bh )
                    timer.performWithDelay( 2000, endGame )
                else
                    bh.alpha = 0
                    timer.performWithDelay( 1000, restoreBh )
                end
            end
        end
    elseif   (event) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "bullet" and obj2.myName == "monster2" ) or
             ( obj1.myName == "monster2" and obj2.myName == "bullet" ) )
        then
        -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #monstersTable, 1, -1 do
                if ( monstersTable[i] == obj1 or monstersTable[i] == obj2 ) then
                    table.remove( monstersTable, i )
                    break
                end
            end

            -- Increase score
            score = score - 100
            scoreText.text = " " .. score
            media.playEventSound("Sounds/lostcoin.wav")

            elseif ( ( obj1.myName == "bh" and obj2.myName == "monster2" ) or
                 ( obj1.myName == "monster2" and obj2.myName == "bh" ) )
        	then
        		if ( died == false ) then
        			 died = true

        			 -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives
                if ( lives == 0 ) then
                    display.remove( bh )
                    timer.performWithDelay( 2000, endGame )
                else
                    bh.alpha = 0
                    timer.performWithDelay( 1000, restoreBh )
                end
            end
        end
    elseif   (event) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "bullet" and obj2.myName == "monster3" ) or
             ( obj1.myName == "monster3" and obj2.myName == "bullet" ) )
        then
        -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #monstersTable, 1, -1 do
                if ( monstersTable[i] == obj1 or monstersTable[i] == obj2 ) then
                    table.remove( monstersTable, i )
                    break
                end
            end

            -- Increase score
            score = score - 100
            scoreText.text = " " .. score
            media.playEventSound("Sounds/lostcoin.wav")

            elseif ( ( obj1.myName == "bh" and obj2.myName == "monster3" ) or
                 ( obj1.myName == "monster3" and obj2.myName == "bh" ) )
        	then
        		if ( died == false ) then
        			 died = true

        			 -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives
                if ( lives == 0 ) then
                    display.remove( bh )
                    timer.performWithDelay( 2000, endGame )

                else
                    bh.alpha = 0
                    timer.performWithDelay( 1000, restoreBh )
                end
            end
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
	physics.pause()  -- Temporarily pause the physics engine

	backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

    local background = display.newImageRect(backGroup,"Images/background.png", 565, 315 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	wt = display.newImageRect( mainGroup,"Images/wanted.png", 80, 90)
	wt.x = display.contentWidth -485
	wt.y = display.contentHeight -280

    bh = display.newImageRect( mainGroup,"Images/bh.png", 60, 42 )
	bh.x = display.contentWidth/20
	bh.y = display.contentHeight - 40
	physics.addBody( bh, { radius=30, isSensor=true } )
	bh.myName = "bh"
 
    -- Display lives and score
    livesText = display.newText( uiGroup, "LIVES: " .. lives, 100, 12, "Cartwheel.otf", 16 )
    livesText:setFillColor( 0.1, 0.1, 0.1 )
	scoreText = display.newText( uiGroup, " " .. score, 315, 12, "Cartwheel.otf", 17 )
    scoreText:setFillColor( 0.1, 0.1, 0.1 )

	bullet = display.newImageRect( mainGroup,"Images/button.png", 85, 85 )
	bullet.x = display.contentWidth/1
	bullet.y = display.contentHeight - 40

   	bullet:addEventListener( "tap", fireBullet )
    bh:addEventListener( "touch", dragBh )

    bounty = display.newImageRect( mainGroup,"Images/bounty.png", 18, 20 )
	bounty.x = display.contentWidth/1.4
	bounty.y = display.contentHeight -302
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 2000 )
        audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		 Runtime:removeEventListener( "collision", onCollision )
        	physics.pause()
        	composer.removeScene( "game" )
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
