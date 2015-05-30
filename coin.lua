Class = require 'lib.class'
Vector = require 'lib.vector'

Coin = Class {
	RADIUS = 5,
	INI_ID = 0,
	OBJ_TYPE = 'COIN',
	init = function(self, pos)
		self.TYPE = 'COIN'
		self.pos = pos
		self.id = Coin.INI_ID
		Coin.INI_ID = Coin.INI_ID + 1

		-- Coin Physics
		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'static')
		self.shape = love.physiscs.newCircleShape(RADIUS)
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
