
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local json = require( "json" )
 
local scoresTable = {}
 
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function loadScores()
 
    local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end

local function saveScores()
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function gotoMenu()
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	 -- Load the previous scores
    loadScores()

    -- Insert the saved score from the last game into the table, then reset it
    table.insert( scoresTable, composer.getVariable( "finalScore" ) )
    composer.setVariable( "finalScore", 0 )

    -- Sort the table entries from highest to lowest
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )

      -- Save the scores
    saveScores()

    local background = display.newImageRect( sceneGroup, "Images/menu.jpg", 555, 315 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
     
    --local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44 )

    for i = 1, 6 do
        if ( scoresTable[i] ) then
            local yPos = 108 + ( i * 14 )

            local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX -65, yPos, "Cartwheel.otf", 14 )
            rankNum:setFillColor( 0.4, 0.2, 0.1 )
            rankNum.anchorX = 1
          
            local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX -65, yPos, "Cartwheel.otf", 14 )
            thisScore:setFillColor( 0.4, 0.2, 0.1 )
            thisScore.anchorX = 0

 
        end
    end
    local playButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 40, "Cartwheel.otf", 40 )
	playButton:setFillColor( 0.9, 0.1, 0.1 )

    local menuButton = display.newText( sceneGroup, "Return", display.contentCenterX, 292, "Cartwheel.otf", 20 )
    menuButton:setFillColor( 0.4, 0.2, 0.1 )
    menuButton:addEventListener( "tap", gotoMenu )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

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
		composer.removeScene( "highscores" )
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
