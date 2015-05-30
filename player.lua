Class = require 'lib.class'
Controller = require 'controller'

Player = Class {
	init = function(self, playerNum)
		self.id = playerNum
		self.x, self.y = 200, 200
		self.vx, self.vy = 0, 0
		self.speed = 5
		self.coins = 0
		self.grappleActive = false
		self.grappleX, self.grappleY = 0, 0
		self.controller = Controller(playerNum)
	end
}

function Player:update(dt)
	self.vx = self.controller:LSX() * self.speed
	self.vy = self.controller:LSY() * self.speed
	self.x = self.x + self.vx
	self.y = self.y + self.vy
end

function Player:draw()
	love.graphics.circle('fill', self.x, self.y, 16, 16)
end

return Player
