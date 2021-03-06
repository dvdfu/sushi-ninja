Class = require 'lib.class'
Vector = require 'lib.vector'

Coin = Class {
	RADIUS = 32,
	SUSHI_SPR = {
		love.graphics.newImage('img/sushi1.png'),
		love.graphics.newImage('img/sushi2.png'),
		love.graphics.newImage('img/sushi3.png'),
		love.graphics.newImage('img/sushi4.png')
	},
	SHADOW_SPR = love.graphics.newImage('img/shadow.png'),
	PICKUP_SFX = love.audio.newSource("sfx/sushi.wav"),
	iniId = 1,

	init = function(self, pos)
		self.type = OBJ_TYPE.COIN
		self.pos = pos
		self.id = Coin.iniId
		self.sprite = Coin.SUSHI_SPR[math.random(#Coin.SUSHI_SPR)]

		self.timer = 0

		Coin.iniId = Coin.iniId + 1

		-- Coin Physics
		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'kinematic')
		self.shape = love.physics.newCircleShape(Coin.RADIUS)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
		self.fixture:setSensor(true)
		self.fixture:setGroupIndex(CONSTANTS.PLAYER_INTERACTABLE_FIXTURE_GROUP)

		partSmoke:setPosition(self.pos:unpack())
		partSmoke:emit(40)
	end
}

function Coin:update(dt)
	if self.timer < 1 then
		self.timer = self.timer + dt*0.7
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
	partSparkle:setPosition(self.pos:unpack())
	partSparkle:emit(20)
	self.body:destroy()
end

return Coin
