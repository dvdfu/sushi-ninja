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
		self.prePos = self.pos
		self.vel = Vector(0, 0)
		self.angle = 0
		self.coins = 0
		self.grappleActive = false
		self.grappleCool = 0
		self.grappleCoolMax = 0.5
		self.gPos = self.pos
		self.gVel = Vector(0, 0)
		self.cursorAngle = 0
		self.controller = Controller(playerNum)
		Player.BLUR_SPR:setFilter('nearest', 'nearest')
	end
}

function Player:update(dt)
	self.vel = Vector(0, 0)
	if self.grappleCool < self.grappleCoolMax - 0.1 then
		self.vel = self.vel + Vector(self.controller:LSX(), self.controller:LSY()) * Player.SPEED
	end
	self.pos = self.pos + self.vel
	self.angle = math.atan2(self.controller:LSY(), self.controller:LSX())

	local controllerRSY = self.controller:RSY()
	local controllerRSX = self.controller:RSX()

	if controllerRSY ~= 0 or controllerRSX ~= 0 then
		local da = math.atan2(controllerRSY, controllerRSX) - self.cursorAngle
		local a = (((da % 360) + 540) % 360) - 180
		self.cursorAngle = self.cursorAngle + a / 4
	end

	--grapple logic
	if self.grappleCool > 0 then
		self.grappleCool = self.grappleCool - dt
	else
		self.grappleCool = 0
	end

	if self.grappleActive then
		self.gPos = self.gPos + self.gVel
		self.gVel = self.gVel * 0.92
		if not self.controller:RB() then
			self.grappleActive = false
			self.grappleCool = self.grappleCoolMax
			self.prePos = self.pos
			self.pos = self.gPos
		end
	else
		if self.controller:RB() then
			self.grappleActive = true
			self.gPos = self.pos
			self.gVel = 24 * Vector(math.cos(self.angle), math.sin(self.angle))
		end
	end
end

function Player:draw()
	if self.grappleActive then
		love.graphics.circle('fill', self.gPos.x, self.gPos.y, 5, 5)
	end

	if self.grappleCool > self.grappleCoolMax - 0.1 then
		local grappleAngle = math.atan2(self.gPos.y - self.prePos.y, self.gPos.x - self.prePos.x)
		local xScale = math.pow(self.gPos.y - self.prePos.y, 2) + math.pow(self.gPos.x - self.prePos.x, 2)
		xScale = math.sqrt(xScale) / 64
		love.graphics.setBlendMode('additive')
		local lerp = 10 * (self.grappleCool - self.grappleCoolMax + 0.1)
		love.graphics.setColor(255, 255, 255, 255 * lerp)
		love.graphics.draw(Player.BLUR_SPR, self.prePos.x, self.prePos.y, grappleAngle, xScale, 2, 0, 8)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setBlendMode('alpha')
	end

	love.graphics.circle('fill', self.pos.x, self.pos.y, 16, 16)
	local cursor = Player.CURSOR_RADIUS * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
	love.graphics.circle('fill', self.pos.x + cursor.x, self.pos.y + cursor.y, 5, 5)
end

function canMove()
end

return Player
