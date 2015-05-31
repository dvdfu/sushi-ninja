Class = require 'lib.class'
Vector = require 'lib.vector'

Mine = Class{
	init = function(self, id, x, y, player)
		self.type = 'MINE'
		self.id = id
		self.pos = Vector(x, y)
		self.player = player

		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'kinematic')
		self.shape = love.physics.newCircleShape(5)
		self.fixture = love.physics.newFixture(self.body, self.shape, 0)
		self.fixture:setUserData(self)
	end
}

function Mine:update(dt)
end

function Mine:draw()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.shape:getRadius())
  love.graphics.setColor(255, 255, 255, 255)
end

function Mine:explode()
	for key, mine in pairs(self.player.mines) do
		if key == self.id then
			table.remove(self.player.mines, key).body:destroy()
			self.player.minesCount = self.player.minesCount - 1
			for key, mine in pairs(self.player.mines) do mine:setId(key) end
			return
		end
	end
end

function Mine:setId(id) self.id = id end

return Mine