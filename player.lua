require 'lib.anim'
Class = require 'lib.class'
Vector = require 'lib.vector'
Controller = require 'controller'
Mine = require 'mine'

Player = Class {
	SPEED = 300,
	IDLE_SPR = love.graphics.newImage('img/player_idle.png'),
	RUN_SPR = love.graphics.newImage('img/player_run.png'),
	STUN_SPR = love.graphics.newImage('img/player_stun.png'),
	SHADOW_SPR = love.graphics.newImage('img/shadow.png'),
	BLUR_SPR = love.graphics.newImage('img/blur2.png'),
	STAR_SPR = love.graphics.newImage('img/star.png'),
	BLUR_TIMEOUT = 1 / 20,
 	ROTATION_FACTOR = 0.15,
 	MAX_MINES = 3,
	DASH_SFX = love.audio.newSource("sfx/swoosh.mp3"),
	init = function(self, playerNum)
		self.type = OBJ_TYPE.PLAYER
		self.id = playerNum
		self.pos = Vector((playerNum * 2 - 1) * CONSTANTS.SCREEN_WIDTH / 4,
			CONSTANTS.SCREEN_HEIGHT / 2)
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
		self.body:setMass(10000)
		self.shape = love.physics.newCircleShape(32)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.fixture:setUserData(self)
		self.fixture:setCategory(self.id)
		self.fixture:setMask(self.id)
		self.fixture:setGroupIndex(CONSTANTS.PLAYER_COIN_FIXTURE_GROUP)

 		self.idleAnim = newAnimation(Player.IDLE_SPR, 32, 32, 0.4, 0)
 		self.runAnim = newAnimation(Player.RUN_SPR, 32, 32, 0.1, 0)
 		self.stunAnim = newAnimation(Player.STUN_SPR, 32, 32, 0.8, 0)
 		self.anim = self.idleAnim
 		self.starAnim = newAnimation(Player.STAR_SPR, 10, 10, 0.2, 0)

		self.mines = {}
		self.minesCount = 0
		self.preT = 0
		self.hurtTimer = 0
		self.stunTimer = 0

		self.enemy = nil

		partSmoke:setPosition(self.pos:unpack())
		partSmoke:emit(40)
	end
}

function Player:update(dt)
	self.anim:update(dt)
	self.starAnim:update(dt)
	local lsx, lsy = self.controller:LSX(), self.controller:LSY()
	local rsx, rsy = self.controller:RSX(), self.controller:RSY()
	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT

	--stunned
	if self.stunTimer > 0 then
		self.stunTimer = self.stunTimer - dt
	else
		self.stunTimer = 0
	end

	self.vel = Vector(0, 0)
	if self.cursorTimer == 0 and self.stunTimer == 0 then self.vel = self.vel + Vector(lsx, lsy) * Player.SPEED end

	if self.vel:len() > 0 then self.anim = self.runAnim
	else self.anim = self.idleAnim end
	if self.stunTimer > 0 then self.anim = self.stunAnim end

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

		if (rsx == 0 and rsy == 0) or self.stunTimer > 0  then
			self.cursor = false
			self.cursorRadius = 0
		elseif self.controller:RB() or self.controller:LB() then --on dash
			Player.DASH_SFX:stop()
			Player.DASH_SFX:play()
			self.cursor = false
			self.cursorTimer = Player.BLUR_TIMEOUT
			self.oldPos = self.pos
			self.body:setPosition((self.pos + self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))):unpack())
		end
	else
		if self.cursorTimer == 0 and not (self.controller:RB() or self.controller:LB()) and (rsx ~= 0 or rsy ~= 0) and self.stunTimer == 0  then
			self.cursor = true
			self.cursorRadius = 0
			self.cursorVelocity = 10
		end
	end

	if love.timer.getTime() - self.preT > 0.5 and (self.controller:RT() == 1 or self.controller:LT() == 1)and self.stunTimer == 0  then
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
		self.body:setPosition(self.pos.x + sWidth, self.pos.y)
	elseif self.pos.x > sWidth then
		self.body:setPosition(self.pos.x - sWidth, self.pos.y)
	end

	if self.pos.y < 0 then
		self.body:setPosition(self.pos.x, self.pos.y + sHeight)
	elseif self.pos.y > sHeight then
		self.body:setPosition(self.pos.x, self.pos.y - sHeight)
	end


end

function Player:draw()
	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT

	for key, mine in pairs(self.mines) do mine:draw() end

	self:drawOffset(0, 0)
	self:drawOffset(sWidth, 0)
	self:drawOffset(-sWidth, 0)
	self:drawOffset(0, sHeight)
	self:drawOffset(0, -sHeight)
end

function Player:drawOffset(ox, oy)
	love.graphics.setColor(P_COLOUR[self.id].r, P_COLOUR[self.id].g, P_COLOUR[self.id].b)

	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT

	if self.cursor then
		local cursorPos = self.cursorRadius * Vector(math.cos(self.cursorAngle), math.sin(self.cursorAngle))
		love.graphics.draw(Player.SHADOW_SPR, self.pos.x + cursorPos.x + ox, self.pos.y + cursorPos.y + oy + 8, 0, 2, 2, 16, 16)
	else
		love.graphics.draw(Player.SHADOW_SPR, self.pos.x + ox, self.pos.y + oy + 8, 0, 2, 2, 16, 16)
	end

	if self.cursorTimer > 0 then love.graphics.draw(Player.BLUR_SPR, self.oldPos.x + ox, self.oldPos.y + oy, self.cursorAngle, (self.cursorRadius + 16) / 128, 2, 0, 16) end
	self.anim:draw(self.body:getX() + ox, self.body:getY() + oy, 0, 2 * self.direction, 2, 16, 16)

	love.graphics.setColor(255, 255, 255)

	if self.stunTimer > 0 then
		for i = 0, 4 do
			local angle = self.stunTimer * math.pi * 2 + math.pi * 2 * i / 5
			local x, y = 32 * math.cos(angle), 16 * math.sin(angle)
			self.starAnim:draw(self.body:getX() + x + ox, self.body:getY() - 48 + y + oy, 0, 2, 2, 5, 5)
		end
	end
end

function Player:dropMine()
	self.minesCount = self.minesCount + 1
	if self.minesCount > Player.MAX_MINES then
		self.mines[Player.MAX_MINES]:explode(true)
	end
	table.insert(self.mines, 1, Mine(1, self.pos.x, self.pos.y, self))
	for key, mine in pairs(self.mines) do mine:setId(key) end
end

function Player:getPos()
	return self.pos
end

function Player:getMines()
	return self.mines
end

function Player:getCoins()
	return self.coins
end

function Player:collectCoin()
	self.coins = self.coins + 1
	-- print('Player ', self.id, ': ', self.coins, ' coins')
	return self.coins
end

function Player:setEnemy(enemy)
	self.enemy = enemy
end

function Player:stun()
	if self.stunTimer == 0 then self.stunTimer = 2 end
end

return Player
