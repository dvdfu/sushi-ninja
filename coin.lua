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
	init = function(self, pos)
		self.type = OBJ_TYPE.COIN
		self.pos = pos
		self.id = Coin.INI_ID
		self.sprite = Coin.SUSHI_SPR[math.random(#Coin.SUSHI_SPR)]

		Coin.INI_ID = Coin.INI_ID + 1

		-- Coin Physics
		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'static')
		self.shape = love.physics.newCircleShape(Coin.RADIUS)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
		self.fixture:setGroupIndex(CONSTANTS.PLAYER_COIN_FIXTURE_GROUP)
	end
}

function Coin:update(dt)

end

function Coin:draw()
	love.graphics.draw(self.sprite, self.pos.x, self.pos.y, 0, 2, 2, 16, 16)
end

function Coin:delete()
	self.body:destroy()
end

return Coin
