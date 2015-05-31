Class = require 'lib.class'
Vector = require 'lib.vector'

Coin = Class {
	RADIUS = 5,
	INI_ID = 1,
	OBJ_TYPE = 'COIN',
	init = function(self, pos)
		self.TYPE = Coin.OBJ_TYPE
		self.pos = pos
		self.id = Coin.INI_ID
		Coin.INI_ID = Coin.INI_ID + 1

		-- Coin Physics
		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'static')
		self.shape = love.physics.newCircleShape(Coin.RADIUS)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
	end
}

function Coin:update(dt)

end

function Coin:draw()
	-- Set draw to Yellow
	love.graphics.setColor(255, 255, 0)
	love.graphics.circle('line', self.pos.x, self.pos.y, Coin.RADIUS, 10)
	love.graphics.setColor(255, 255, 255)
end

return Coin
