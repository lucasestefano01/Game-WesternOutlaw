local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- variaveis locais
local lives = 3
local score = 0
local died = false
 
local monstersTable = {}
 
local bh
local gameLoopTimer
local livesText
local scoreText

local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score


-- subindo o background
local background = display.newImageRect(backGroup,"Images/background3.jpg", 550, 300 )
background.x = display.contentCenterX
background.y = display.contentCenterY


--carregando cartaz
bh = display.newImageRect( mainGroup,"Images/wanted.png", 85, 120)
bh.x = display.contentWidth /700
bh.y = display.contentHeight -260

--subindo o personagem
bh = display.newImageRect( mainGroup,"Images/bh.png", 60, 60 )
bh.x = display.contentWidth/20
bh.y = display.contentHeight - 40
physics.addBody( bh, { radius=30, isSensor=true } )
bh.myName = "bh"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 215, 30, native.systemFont, 30 )
scoreText = display.newText( uiGroup, " " .. score, 395, 30, native.systemFont, 30 )
display.setStatusBar( display.HiddenStatusBar )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

--atualizar score
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "" .. score
end

coin = display.newImageRect( mainGroup,"Images/coin.gif", 35, 35 )
coin.x = display.contentWidth/1.2
coin.y = display.contentHeight -240


--função gerar inimigos especiais
local function createMonster()
	newMonster1 = display.newImageRect( mainGroup,"Images/enemy1.png", 55, 55 )
	newMonster1.x = display.contentWidth + 50
 	table.insert( monstersTable, newMonster1 )
    physics.addBody( newMonster1, "dynamic", { radius=40, bounce=0.8 } )
 	newMonster1.myName = "monster1"

 	newMonster2 = display.newImageRect( mainGroup,"Images/enemy2.png", 55, 55 )
 	newMonster2.x = display.contentWidth + 50
 	table.insert( monstersTable, newMonster2 )
    physics.addBody( newMonster2, "dynamic", { radius=40, bounce=0.8 } )
 	newMonster2.myName = "monster2"

 	newMonster3 = display.newImageRect( mainGroup,"Images/enemy3.png", 55, 55 )
 	newMonster3.x = display.contentWidth + 50
 	table.insert( monstersTable, newMonster3 )
    physics.addBody( newMonster3, "dynamic", { radius=40, bounce=0.8 } )
 	newMonster3.myName = "monster3"
	

 	local whereFrom = math.random(3)

 	if ( whereFrom == 1) then
        -- From the right
        newMonster1.x = display.contentWidth + 40
        newMonster1.y = ( 220 ) -- posição
        newMonster1:setLinearVelocity( -100, math.random (2,15)) --trajeto, velocidade
    elseif ( whereFrom == 2 ) then
        --From the right
        newMonster2.x = display.contentWidth + 40
        newMonster2.y =( 220 )
       newMonster2:setLinearVelocity(-100, math.random (2,15) )
    elseif ( whereFrom == 3 ) then
        --From the right
        newMonster3.x = display.contentWidth + 40
        newMonster3.y =( 220 )
       newMonster3:setLinearVelocity(-100, math.random (2,15) )  
	end
end

-- função atirar
local function fireBullet()
    local newBullet = display.newImageRect( mainGroup, "Images/bullet.png", 25, 25 )
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

bullet = display.newImageRect( mainGroup,"Images/target.png", 100, 100 )
bullet.x = display.contentWidth/1
bullet.y = display.contentHeight - 40


bullet:addEventListener( "tap", fireBullet )

-- função movimentação do personagem
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
 

bh:addEventListener( "touch", dragBh )

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

gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 2000 )

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

                else
                    bh.alpha = 0
                    timer.performWithDelay( 1000, restoreBh )
                end
            end
        end    
    end
end

Runtime:addEventListener( "collision", onCollision )