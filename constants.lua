Class = require 'lib.class'
Vector = require 'lib.vector'

CONSTANTS = Class {
	SCREEN_WIDTH = love.graphics.getWidth(),
	SCREEN_HEIGHT = love.graphics.getHeight(),
	X_MARGIN = love.graphics.getWidth() * 0.05,
	Y_MARGIN = love.graphics.getHeight() * 0.05,
	COIN_SPAWN_FREQUENCY = 1.5,
	MAX_COINS_ON_SCREEN = 250,
	MIN_COIN_DIST2_FROM_PLAYER = 50000,
	DEFAULT_MAX_ITEMS_ON_SCREEN = 1000, -- of a given object
	PLAYER_COIN_FIXTURE_GROUP = 1,
	NUM_PLAYERS = 2,
	MAX_COINS = 20,
	HOOYAH = love.audio.newSource("sfx/hooyah.wav"),
	SCORE_LABEL = 'Player %i: %i Sushi'
}

OBJ_TYPE = {
	PLAYER = 'PLAYER',
	MINE = 'MINE',
	COIN = 'COIN'
}

P_COLOUR = {
	{r = 255, g = 255, b = 0},
	{r = 0, g = 255, b = 255}
}

return CONSTANTS
