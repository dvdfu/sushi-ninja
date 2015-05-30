Class = require 'lib.class'
Controller = require 'controller'

Player = Class {
	SPEED = 5,
	CURSOR_RADIUS = 80,
	PI = 3.14159265358,
	ROTATION_FACTOR = 0.2,
	init = function(self, playerNum)
		self.id = playerNum
		self.x, self.y = 200, 200
		self.vx, self.vy = 0, 0
		self.coins = 0
		self.grappleActive = false
		self.grappleX, self.grappleY = 0, 0
		self.cursorAngle = 0
		self.lastAngle = 0
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
		local angle = math.atan2(controllerRSY, controllerRSX)
		print(angle)
	    -- Did the angle flip from +Pi to -Pi, or -Pi to +Pi?
	    if self.lastAngle < -2.5 and angle > 2.5 then
	        self.cursorAngle = self.cursorAngle + (Player.PI*2.0)
	    elseif self.lastAngle > 2.5 and angle < -2.5 then
	        self.cursorAngle = self.cursorAngle - Player.PI * 2.0
	    end
	 
	    self.lastAngle = angle
    	self.cursorAngle = (angle*Player.ROTATION_FACTOR) + (self.cursorAngle*(1.0 - Player.ROTATION_FACTOR))
	end
end

function Player:draw()
	love.graphics.circle('fill', self.x, self.y, 16, 16)
	local cursorX = Player.CURSOR_RADIUS * math.cos(self.cursorAngle)
	local cursorY = Player.CURSOR_RADIUS * math.sin(self.cursorAngle)
	love.graphics.circle('fill', self.x + cursorX, self.y + cursorY, 5, 5)
end

return Player
