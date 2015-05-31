Class = require 'lib.class'
Vector = require 'lib.vector'
Controller = require 'controller'
Mine = require 'mine'

Player = Class {
	SPEED = 500,
	BLUR_SPR = love.graphics.newImage('img/blur.png'),
	BLUR_TIMEOUT = 1 / 20,
 	ROTATION_FACTOR = 0.15,
	init = function(self, playerNum)
		self.type = 'PLAYER'
		self.id = playerNum
		self.pos = Vector(playerNum*475, 420)
		self.oldPos = self.pos
		self.vel = Vector(0, 0)

		self.cursorAngle = 0
		self.cursorRadius = 0
		self.cursorVelocity = 0
		self.cursor = false
		self.cursorTimer = 0
		self.cursorLastAngle = 0

		self.coins = 0
		self.controller = Controller(playerNum)

		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'dynamic')
		self.shape = love.physics.newCircleShape(16)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
		self.fixture:setCategory(self.id)
		self.fixture:setMask(self.id)

		Player.BLUR_SPR:setFilter('nearest', 'nearest')

		self.mines = {}
		self.minesCount = 0
		self.preT = 0

		self.coinCount = 0
	end
}

function Player:update(dt)
	for i = 1, #self.mines do self.mines[i]:setId(i) end
	local lsx, lsy = self.controller:LSX(), self.controller:LSY()
	local rsx, rsy = self.controller:RSX(), self.controller:RSY()

	self.vel = Vector(0, 0)
	if self.cursorTimer == 0 then
		self.vel = self.vel + Vector(self.controller:LSX(), self.controller:LSY()) * Player.SPEED
	end
	self.body:setLinearVelocity(self.vel:unpack())
	self.pos = Vector(self.body:getX(), self.body:getY())

	--cursor logic
	if self.cursorTimer > 0 then
		self.cursorTimer = self.cursorTimer - dt
	else
		self.cursorTimer = 0
	end

	if self.cursor then
		self.cursorVelocity = self.cursorVelocity * 0.95
		self.cursorRadius = self.cursorRadius + self.cursorVelocity

 		local angle = math.atan2(rsy, rsx)
 	    if self.cursorLastAngle < -2.0 and angle > 2.0 then
	        self.cursorAngle = self.cursorAngle + (math.pi*2.0)
 	    elseif self.cursorLastAngle > 2.0 and angle < -2.0 then
	        self.cursorAngle = self.cursorAngle - math.pi * 2.0
 	    end
 	    self.cursorLastAngle = angle
     	self.cursorAngle = (angle*Player.ROTATION_FACTOR) + (self.cursorAngle*(1.0 - Player.ROTATION_FACTOR))

		if rsx == 0 and rsy == 0 then
			self.cursor = false
		elseif self.controller:RB() then
			self.cursor = false
			self.cursorTimer = Player.BLUR_TIMEOUT
			self.oldPos = self.pos
			-- self.pos = self.pos + self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
			self.body:setPosition((self.pos + self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))):unpack())
		end
	else
		if self.cursorTimer == 0 and not self.controller:RB() and (rsx ~= 0 or rsy ~= 0) then
			self.cursor = true
			self.cursorRadius = 0
			self.cursorVelocity = 16
		end
	end

	if love.timer.getTime() - self.preT > 0.5 and self.controller:RT() == 1 then
		self:dropMine()
		self.preT = love.timer.getTime()
	end

	-- self.body:setPosition(self.pos.x, self.pos.y)
end

function Player:draw()
	for key, mine in pairs(self.mines) do mine:draw() end

	love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())

	if self.cursorTimer > 0 then
		love.graphics.setBlendMode('additive')
		love.graphics.setColor(255, 255, 255, 255 * (self.cursorTimer / Player.BLUR_TIMEOUT))
		love.graphics.draw(Player.BLUR_SPR, self.oldPos.x, self.oldPos.y, self.cursorAngle, (self.cursorRadius + 16) / 128, 1, 0, 16)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setBlendMode('alpha')
	end

	if self.cursor then
		local cursorPos = self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
		love.graphics.circle('line', self.pos.x + cursorPos.x, self.pos.y + cursorPos.y, 16)
		-- love.graphics.line(self.pos.x, self.pos.y, self.pos.x + cursorPos.x, self.pos.y + cursorPos.y)
		-- love.graphics.circle('line', self.pos.x, self.pos.y, self.cursorRadius)
	end

	-- love.graphics.circle('fill', self.pos.x, self.pos.y, 16)
end

function Player:dropMine()
	self.minesCount = self.minesCount + 1
	if self.minesCount > 5 then
		self.mines[5]:explode()
	end
	table.insert(self.mines, 1, Mine(1, self.pos.x, self.pos.y, self))
	for key, mine in pairs(self.mines) do mine:setId(key) end
end

function Player:getMines()
	return self.mines
end

function Player:collectCoin()
	self.coinCount = self.coinCount + 1
	return self.coinCount
end

return Player
