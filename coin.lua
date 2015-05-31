Class = require 'lib.class'
Vector = require 'lib.vector'

Coin = Class {
	RADIUS = 5,
	INI_ID = 1,
	SUSHI1_SPR = love.graphics.newImage('img/sushi1.png'),
	SUSHI2_SPR = love.graphics.newImage('img/sushi2.png'),
	init = function(self, pos)
		self.type = OBJ_TYPE.COIN
		self.pos = pos
		self.id = Coin.INI_ID
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
	-- Set draw to Yellow
	-- love.graphics.setColor(255, 255, 0)
	-- love.graphics.circle('line', self.pos.x, self.pos.y, Coin.RADIUS, 10)
	-- love.graphics.setColor(255, 255, 255)
	love.graphics.draw(Coin.SUSHI1_SPR, self.pos.x, self.pos.y, 0, 2, 2, 16, 16)
end

function Coin:delete()
	self.body:destroy()
end

return Coin
