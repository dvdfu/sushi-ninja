Class = require 'lib.class'
Vector = require 'lib.vector'

Coin = Class {
	RADIUS = 32,
	INI_ID = 1,
	SUSHI_SPR = {
		love.graphics.newImage('img/sushi1.png'),
		love.graphics.newImage('img/sushi2.png'),
		love.graphics.newImage('img/sushi3.png')
	},
	SHADOW_SPR = love.graphics.newImage('img/shadow.png'),
	PICKUP_SFX = love.audio.newSource("sfx/sushi.wav"),

	init = function(self, pos)
		self.type = OBJ_TYPE.COIN
		self.pos = pos
		self.id = Coin.INI_ID
		self.sprite = Coin.SUSHI_SPR[math.random(#Coin.SUSHI_SPR)]

		self.timer = 0

		Coin.INI_ID = Coin.INI_ID + 1

		-- Coin Physics
		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'static')
		self.shape = love.physics.newCircleShape(Coin.RADIUS)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
		self.fixture:setSensor(true)
		self.fixture:setGroupIndex(CONSTANTS.PLAYER_COIN_FIXTURE_GROUP)
	end
}

function Coin:update(dt)
	if self.timer < 1 then
		self.timer = self.timer + dt
	else
		self.timer = self.timer - 1
	end
end

function Coin:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.draw(Coin.SHADOW_SPR, self.pos.x, self.pos.y+8, 0, 2, 2, 16, 16)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.sprite, self.pos.x, self.pos.y + 4 * math.sin(self.timer * math.pi * 2), 0, 2, 2, 16, 16)
end

function Coin:delete()
	Coin.PICKUP_SFX:stop()
	Coin.PICKUP_SFX:play()
	self.body:destroy()
end

return Coin
