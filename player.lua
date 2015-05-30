Class = require 'lib.class'
Controller = require 'controller'

Player = Class {
	SPEED = 5,
	CURSOR_RADIUS = 40,
	init = function(self, playerNum)
		self.id = playerNum
		self.x, self.y = 200, 200
		self.vx, self.vy = 0, 0
		self.coins = 0
		self.grappleActive = false
		self.grappleX, self.grappleY = 0, 0
		self.cursorX, self.cursorY = 24, 24
		self.controller = Controller(playerNum)
	end
}

function Player:update(dt)
	self.vx = self.controller:LSX() * Player.SPEED
	self.vy = self.controller:LSY() * Player.SPEED
	self.x = self.x + self.vx
	self.y = self.y + self.vy

	controllerRSY = self.controller:RSY()
	controllerRSX = self.controller:RSX()

	if controllerRSY ~= 0 or controllerRSX ~= 0 then
		angle = math.atan2(controllerRSY, controllerRSX)
		self.cursorX = Player.CURSOR_RADIUS * math.cos(angle)
		self.cursorY = Player.CURSOR_RADIUS * math.sin(angle)
	end
end

function Player:draw()
	love.graphics.circle('fill', self.x, self.y, 16, 16)
	love.graphics.circle('fill', self.x + self.cursorX, self.y + self.cursorY, 5, 5)
end

return Player
