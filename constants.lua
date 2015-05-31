Class = require 'lib.class'

CONSTANTS = Class {
	SCREEN_WIDTH = love.graphics.getWidth(),
	SCREEN_HEIGHT = love.graphics.getHeight(),
	X_MARGIN = love.graphics.getWidth() * 0.05,
	Y_MARGIN = love.graphics.getHeight() * 0.05,
	COIN_SPAWN_FREQUENCY = 1.5,
	PLAYER_COIN_FIXTURE_GROUP = 1,
	NUM_PLAYERS = 2,
	SCORE_LABEL = 'Player %i: %i Sushi'
}

OBJ_TYPE = {
	PLAYER = 'PLAYER',
	MINE = 'MINE',
	COIN = 'COIN'
}

return CONSTANTS
