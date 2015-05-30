Class = require 'lib.class'

Player = Class {
	init = function(self, playerNum)
		self.id = playerNum
		self.x, self.y = 200, 200
		self.vx, self.vy = 0, 0
		self.vMax = 6
		self.coins = 0
		self.grappleActive = false
		self.grappleX, self.grappleY = 0, 0
	end
}

function Player:update(dt)
	if love.keyboard.isDown('w') then
		if self.vy > -self.vMax then
			self.vy = self.vy - 0.4
		else
			self.vy = -self.vMax
		end
	elseif love.keyboard.isDown('s') then
		if self.vy < self.vMax then
			self.vy = self.vy + 0.4
		else
			self.vy = self.vMax
		end
	else
		self.vy = 0
	end
	self.y = self.y + self.vy
end

function Player:draw()
	love.graphics.circle('fill', self.x, self.y, 24, 24)
end

return Player