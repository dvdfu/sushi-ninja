Class = require 'lib.class'
Vector = require 'lib.vector'

Mine = Class{
	KNOCK_BACK = 20,
	DANGER_PROXIMITY = 100,
	init = function(self, id, x, y, player)
		self.type = OBJ_TYPE.MINE
		self.id = id
		self.pos = Vector(x, y)
		self.player = player

		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'kinematic')
		self.shape = love.physics.newCircleShape(32)
		self.fixture = love.physics.newFixture(self.body, self.shape, 0)
		self.fixture:setUserData(self)
		self.fixture:setCategory(self.player.id)
		self.fixture:setMask(self.player.id)
	end
}

function Mine:update(dt)
end

function Mine:draw()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
  love.graphics.setColor(255, 255, 255, 255)
end

function Mine:explode()
	for key, mine in pairs(self.player.mines) do
		if key == self.id then
			local mine = table.remove(self.player.mines, key)
			local diff = mine.pos - self.player.enemy.pos
			if diff:len() < Mine.DANGER_PROXIMITY then
				self.player.enemy.body:applyLinearImpulse(-diff.x*Mine.KNOCK_BACK,-diff.y*Mine.KNOCK_BACK)
				self.player.enemy.hurtTimer = 0.1
			end
			mine.body:destroy()
			self.player.minesCount = self.player.minesCount - 1
			for key, mine in pairs(self.player.mines) do mine:setId(key) end
			return
		end
	end
end

function Mine:setId(id) self.id = id end

return Mine
