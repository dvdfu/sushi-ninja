Class = require 'lib.class'
Vector = require 'lib.vector'
Controller = require 'controller'

Player = Class {
	SPEED = 5,
	CURSOR_RADIUS = 80,
	BLUR_SPR = love.graphics.newImage('img/blur.png'),
	init = function(self, playerNum)
		self.id = playerNum
		self.pos = Vector(200, 200)
		self.vel = Vector(0, 0)
		self.coins = 0
		self.grappleActive = false
		self.gPos = Vector(0, 0)
		self.gVel = Vector(0, 0)
		self.cursorAngle = 0
		self.controller = Controller(playerNum)
	end
}

function Player:update(dt)
	self.vel = Vector(self.controller:LSX(), self.controller:LSY()) * Player.SPEED
	self.pos = self.pos + self.vel

	controllerRSY = self.controller:RSY()
	controllerRSX = self.controller:RSX()

	if controllerRSY ~= 0 or controllerRSX ~= 0 then
		local da = math.atan2(controllerRSY, controllerRSX) - self.cursorAngle
		local a = (((da % 360) + 540) % 360) - 180
		self.cursorAngle = self.cursorAngle + a / 4
	end

	--grapple logic
	if self.grappleActive then
		self.gPos = self.gPos + self.gVel + self.vel
		self.gVel = self.gVel * 0.95
		if not self.controller:RB() then
			self.grappleActive = false
			self.pos = self.gPos
		end
	else
		if self.controller:RB() then
			self.grappleActive = true
			self.gPos = self.pos
			self.gVel = 16 * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
		end
	end
end

function Player:draw()
	love.graphics.circle('fill', self.pos.x, self.pos.y, 16, 16)
	local cursor = Player.CURSOR_RADIUS * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
	love.graphics.circle('fill', self.pos.x + cursor.x, self.pos.y + cursor.y, 5, 5)

	if self.grappleActive then
		love.graphics.circle('fill', self.gPos.x, self.gPos.y, 5, 5)
	end

	local grappleAngle = math.atan2(self.gPos.y - self.pos.y, self.gPos.x - self.pos.x)
	local xScale = math.pow(self.gPos.y - self.pos.y, 2) + math.pow(self.gPos.x - self.pos.x, 2)
	xScale = math.sqrt(xScale) / 32
	love.graphics.draw(Player.BLUR_SPR, self.pos.x, self.pos.y, grappleAngle, xScale, 2, 0, 4)
end

return Player
