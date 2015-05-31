require 'lib.anim'
Class = require 'lib.class'
Vector = require 'lib.vector'
Controller = require 'controller'
Mine = require 'mine'

Player = Class {
	SPEED = 300,
	IDLE_SPR = love.graphics.newImage('img/player_idle.png'),
	RUN_SPR = love.graphics.newImage('img/player_run.png'),
	BLUR_SPR = love.graphics.newImage('img/blur.png'),
	BLUR_TIMEOUT = 1 / 20,
 	ROTATION_FACTOR = 0.15,
	init = function(self, playerNum)
		self.type = OBJ_TYPE.PLAYER
		self.id = playerNum
		self.pos = Vector(playerNum*475, 420)
		self.oldPos = self.pos
		self.vel = Vector(0, 0)
		self.direction = 1

		self.cursorAngle = 0
		self.cursorRadius = 0
		self.cursorVelocity = 0
		self.cursor = false
		self.cursorTimer = 0
		self.cursorLastAngle = 0

		self.coins = 0
		self.controller = Controller(playerNum)

		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'dynamic')
		self.shape = love.physics.newCircleShape(32)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
		self.fixture:setCategory(self.id)
		self.fixture:setMask(self.id)
		self.fixture:setGroupIndex(CONSTANTS.PLAYER_COIN_FIXTURE_GROUP)

		Player.BLUR_SPR:setFilter('nearest', 'nearest')
		Player.IDLE_SPR:setFilter('nearest', 'nearest')
		Player.RUN_SPR:setFilter('nearest', 'nearest')

 		self.idleAnim = newAnimation(Player.IDLE_SPR, 32, 32, 0.4, 0)
 		self.runAnim = newAnimation(Player.RUN_SPR, 32, 32, 0.1, 0)
 		self.anim = self.idleAnim

		self.mines = {}
		self.minesCount = 0
		self.preT = 0
		self.hurtTimer = 0

		self.enemy = nil
	end
}

function Player:update(dt)
	self.anim:update(dt)
	local lsx, lsy = self.controller:LSX(), self.controller:LSY()
	local rsx, rsy = self.controller:RSX(), self.controller:RSY()
	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT

	self.vel = Vector(0, 0)
	if self.cursorTimer == 0 then self.vel = self.vel + Vector(lsx, lsy) * Player.SPEED end

	if self.vel:len() > 0 then self.anim = self.runAnim
	else self.anim = self.idleAnim end

	if self.vel.x > 0 then self.direction = 1
	elseif self.vel.x < 0 then self.direction = -1 end

	if self.hurtTimer > 0 then self.hurtTimer = self.hurtTimer - dt
	else
		self.body:setLinearVelocity(self.vel:unpack())
		self.pos = Vector(self.body:getX(), self.body:getY())
		self.hurtTimer = 0
	end

	--cursor logic
	if self.cursorTimer > 0 then self.cursorTimer = self.cursorTimer - dt
	else self.cursorTimer = 0 end

	if self.cursor then
		self.cursorVelocity = self.cursorVelocity * 0.97
		self.cursorRadius = self.cursorRadius + self.cursorVelocity

 		local angle = math.atan2(rsy, rsx)
 	    if self.cursorLastAngle < -2.0 and angle > 2.0 then self.cursorAngle = self.cursorAngle + (math.pi*2.0)
 	    elseif self.cursorLastAngle > 2.0 and angle < -2.0 then self.cursorAngle = self.cursorAngle - math.pi * 2.0 end
 	    self.cursorLastAngle = angle
     	self.cursorAngle = (angle*Player.ROTATION_FACTOR) + (self.cursorAngle*(1.0 - Player.ROTATION_FACTOR))

		if rsx == 0 and rsy == 0 then self.cursor = false
		elseif self.controller:RB() then
			self.cursor = false
			self.cursorTimer = Player.BLUR_TIMEOUT
			self.oldPos = self.pos
			self.body:setPosition((self.pos + self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))):unpack())
		end
	else
		if self.cursorTimer == 0 and not self.controller:RB() and (rsx ~= 0 or rsy ~= 0) then
			self.cursor = true
			self.cursorRadius = 0
			self.cursorVelocity = 10
		end
	end

	if love.timer.getTime() - self.preT > 0.5 and self.controller:RT() == 1 then
		self:dropMine()
		self.preT = love.timer.getTime()
	end


	-- KEYBOARD CONTROLS: UNCOMMENT TO USE
	-- if love.keyboard.isDown('w') then
	-- 	self.body:setPosition(self.pos.x, self.pos.y - 7)
	-- end
	-- if love.keyboard.isDown('a') then
	-- 	self.body:setPosition(self.pos.x - 7, self.pos.y)
	-- end
	-- if love.keyboard.isDown('s') then
	-- 	self.body:setPosition(self.pos.x, self.pos.y + 7)
	-- end
	-- if love.keyboard.isDown('d') then
	-- 	self.body:setPosition(self.pos.x + 7, self.pos.y)
	-- end

	if self.pos.x < 0 then
		self.body:setPosition(sWidth, self.pos.y)
	elseif self.pos.x > sWidth then
		self.body:setPosition(0, self.pos.y)
	end

	if self.pos.y < 0 then
		self.body:setPosition(self.pos.x, sHeight)
	elseif self.pos.y > sHeight then
		self.body:setPosition(self.pos.x, 0)
	end


end

function Player:draw()
	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT
	for key, mine in pairs(self.mines) do mine:draw() end
	if self.cursor then
		local cursorPos = self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
		love.graphics.circle('line', self.pos.x + cursorPos.x, self.pos.y + cursorPos.y, 16)
	end

	if self.id == 1 then love.graphics.setColor(255, 255, 0)
	else love.graphics.setColor(0, 255, 255) end

	if self.cursorTimer > 0 then love.graphics.draw(Player.BLUR_SPR, self.oldPos.x, self.oldPos.y, self.cursorAngle, (self.cursorRadius + 16) / 128, 2, 0, 16) end

	self.anim:draw(self.body:getX(), self.body:getY(), 0, 2 * self.direction, 2, 16, 16)

	if self.pos.x < sWidth / 2 or self.pos.x > sWidth / 2 then
		self.anim:draw(self.body:getX() % CONSTANTS.SCREEN_WIDTH, self.body:getY(), 0, 2 * self.direction, 2, 16, 16)
	end

	if self.pos.y < sHeight / 2 or self.pos.y > sHeight / 2 then
		self.anim:draw(self.body:getX(), self.body:getY() % CONSTANTS.SCREEN_HEIGHT, 0, 2 * self.direction, 2, 16, 16)
	end
	love.graphics.setColor(255, 255, 255)
end

function Player:dropMine()
	self.minesCount = self.minesCount + 1
	if self.minesCount > 5 then self.mines[5]:explode() end
	table.insert(self.mines, 1, Mine(1, self.pos.x, self.pos.y, self))
	for key, mine in pairs(self.mines) do mine:setId(key) end
end

function Player:getMines()
	return self.mines
end

function Player:collectCoin()
	self.coins = self.coins + 1
	print('Player ', self.id, ': ', self.coins, ' coins')
	return self.coins
end

function Player:setEnemy(enemy)
	self.enemy = enemy
end

function Player:getCoins()
	return self.coins
end

return Player
