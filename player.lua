Class = require 'lib.class'
Vector = require 'lib.vector'
Controller = require 'controller'

Player = Class {
	SPEED = 5,
	BLUR_SPR = love.graphics.newImage('img/blur.png'),
	BLUR_TIMEOUT = 1 / 20,
	init = function(self, playerNum)
		self.id = playerNum
		self.pos = Vector(playerNum*475, 420)
		self.oldPos = self.pos
		self.vel = Vector(0, 0)
		self.cursorAngle = 0
		self.cursorRadius = 0
		self.cursorVelocity = 0
		self.cursor = false
		self.cursorTimer = 0
		self.coins = 0
		self.controller = Controller(playerNum)
		Player.BLUR_SPR:setFilter('nearest', 'nearest')
	end
}

function Player:update(dt)
	local lsx, lsy = self.controller:LSX(), self.controller:LSY()
	local rsx, rsy = self.controller:RSX(), self.controller:RSY()

	self.vel = Vector(0, 0)
	if self.cursorTimer == 0 then
		self.vel = self.vel + Vector(self.controller:LSX(), self.controller:LSY()) * Player.SPEED
	end
	self.pos = self.pos + self.vel

	--cursor logic
	if self.cursorTimer > 0 then
		self.cursorTimer = self.cursorTimer - dt
	else
		self.cursorTimer = 0
	end

	if self.cursor then
		self.cursorVelocity = self.cursorVelocity * 0.975
		self.cursorRadius = self.cursorRadius + self.cursorVelocity
		self.cursorAngle = math.atan2(rsy, rsx)
		if rsx == 0 and rsy == 0 then
			self.cursor = false
		elseif self.controller:RB() then
			self.cursor = false
			self.cursorTimer = Player.BLUR_TIMEOUT
			self.oldPos = self.pos
			self.pos = self.pos + self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
		end
	else
		if self.cursorTimer == 0 and not self.controller:RB() and (rsx ~= 0 or rsy ~= 0) then
			self.cursor = true
			self.cursorRadius = 0
			self.cursorVelocity = 16
		end
	end
end

function Player:draw()
	if self.cursorTimer > 0 then
		love.graphics.setBlendMode('additive')
		love.graphics.setColor(255, 255, 255, 255 * (self.cursorTimer / Player.BLUR_TIMEOUT))
		love.graphics.draw(Player.BLUR_SPR, self.oldPos.x, self.oldPos.y, self.cursorAngle, (self.cursorRadius + 16) / 128, 1, 0, 16)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setBlendMode('alpha')
	end

	if self.cursor then
		local cursorPos = self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
		love.graphics.circle('fill', self.pos.x + cursorPos.x, self.pos.y + cursorPos.y, 5, 5)
	end

	love.graphics.circle('fill', self.pos.x, self.pos.y, 16, 16)
end

return Player
