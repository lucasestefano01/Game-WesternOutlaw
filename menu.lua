local musicTrack
local composer = require( "composer" )


local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()

	composer.gotoScene( "game", { time=800, effect="crossFade" } )
	audio.stop( 1 )
end

local function gotoHighScores()
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
		local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "Images/menu.jpg", 555, 315 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local playButton = display.newText( sceneGroup, "OBJECTIVES", display.contentCenterX, 185, "Cartwheel.otf", 20 )
	playButton:setFillColor( 0.4, 0.2, 0.1 )

	local playButton = display.newText( sceneGroup, "Western", display.contentCenterX, 25, "Cartwheel.otf", 49 )
	playButton:setFillColor( 0.9, 0.1, 0.1 )

	local playButton = display.newText( sceneGroup, "Outlaw", display.contentCenterX, 55, "Cartwheel.otf", 26 )
	playButton:setFillColor( 0.9, 0.6, 0.1 )

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 125, "Cartwheel.otf", 20 )
	playButton:setFillColor( 0.4, 0.2, 0.1 )

	local highScoresButton = display.newText( sceneGroup, "Scores", display.contentCenterX, 155, "Cartwheel.otf", 20 )
	highScoresButton:setFillColor( 0.4, 0.2, 0.1 )



	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )

	--local backgroundMusic1 = audio.loadStream( "MENU.wav" )

	musicTrack = audio.loadStream( "Sounds/MENU.wav")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		audio.play( musicTrack, { channel=1, loops=-1 } )

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		audio.play( musicTrack, { channel=1, loops=-1 } )

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
