love.graphics.setDefaultFilter('nearest', 'nearest')

Player = require 'player'
ObjSpawner = require 'obj_spawner'
Gamestate = require 'lib.gamestate'
CONSTANTS = require 'constants'
Controller = require 'controller'
Camera = require 'lib.camera'
Vector = require 'lib.vector'
Coin = require 'coin'

local menu = {}
local game = {}
local pause = {}
local over = {}
local winTimer = 0

function menu:enter(to)
	font = love.graphics.getFont()
	self.message = "Press START to play!"
	sushiTimer = 0
	LOGO = love.graphics.newImage('img/logo.png')

	idlePlayerAnim = newAnimation(Player.IDLE_SPR, 32, 32, 0.4, 0)
	menuCoins = {{}, {}}
	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT
	for i = 1, 20 do
		for id in pairs(menuCoins) do
			local sprite = Coin.SUSHI_SPR[math.random(#Coin.SUSHI_SPR)]
			local posX = i * (sWidth + CONSTANTS.MENU_SUSHI_OFFSET) / 20
			local posY = sHeight/2+((id-1) * 2 - 1) * sHeight *2/5
			spriteData = {
				spr = sprite,
				pos = Vector(posX, posY)
			}
			menuCoins[id][i] = spriteData
		end
	end
end

function menu:update(dt)
	local sWidth, sHeight = CONSTANTS.SCREEN_WIDTH, CONSTANTS.SCREEN_HEIGHT
	idlePlayerAnim:update(dt)
	if sushiTimer < 1 then
		sushiTimer = sushiTimer + dt*0.7
	else
		sushiTimer = sushiTimer - 1
	end

	for id in pairs(menuCoins) do
		for i = 1, 20 do
			local offset = CONSTANTS.MENU_SUSHI_OFFSET
			direction = (id * 2) - 3
			menuCoins[id][i].pos.x = menuCoins[id][i].pos.x + (direction * 3)
			if menuCoins[id][i].pos.x < -(offset / 2) then
				menuCoins[id][i].pos.x = menuCoins[id][i].pos.x + sWidth + offset
			elseif menuCoins[id][i].pos.x > sWidth + (offset / 2) then
				menuCoins[id][i].pos.x = menuCoins[id][i].pos.x - sWidth - offset
			end
		end
	end

end

function menu:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.draw(LOGO, CONSTANTS.SCREEN_WIDTH/2, CONSTANTS.SCREEN_HEIGHT/2, 0, 2, 2, 180, 90)
	love.graphics.setColor(255,40,0)
	love.graphics.draw(LOGO, CONSTANTS.SCREEN_WIDTH/2 - 8, CONSTANTS.SCREEN_HEIGHT/2 - 8, 0, 2, 2, 180, 90)
	love.graphics.setColor(255,255,255)
	love.graphics.printf(self.message, 0, CONSTANTS.SCREEN_HEIGHT/2 + 180, CONSTANTS.SCREEN_WIDTH, 'center')

	for i = 1, CONSTANTS.NUM_PLAYERS do
		love.graphics.setColor(P_COLOUR[i].r, P_COLOUR[i].g, P_COLOUR[i].b)
		idlePlayerAnim:draw(CONSTANTS.SCREEN_WIDTH/2 + ((i-1) * 2 - 1) * CONSTANTS.SCREEN_WIDTH / 3,
			CONSTANTS.SCREEN_HEIGHT / 2, 0, 2 * (3-i*2), 2, 16, 16)
	end

	for id in pairs(menuCoins) do
		for i = 1, 20 do
			local spr = menuCoins[id][i].spr
			local pos = menuCoins[id][i].pos
			love.graphics.setColor(0, 0, 0, 128)
			love.graphics.draw(Coin.SHADOW_SPR, pos.x, pos.y+8, 0, 2, 2, 16, 16)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.draw(spr, pos.x, pos.y + 4 * math.sin(sushiTimer * math.pi * 2), 0, 2, 2, 16, 16)
		end
	end

	love.graphics.setColor(255, 255, 255)
end

function menu:leave()
	for id in pairs(menuCoins) do
		for i = 1, 20 do
			menuCoins[id][i] = nil
		end
		menuCoins[id] = nil
	end
	menuCoins = nil
end

-- ENABLE TO ALLOW ENTER KEY TO START GAME
-- function menu:keyreleased(key, code)
--     if key == 'enter' or key == 'return' then
--         Gamestate.switch(game)
--     end
-- end

function menu:joystickreleased(key, code)
	if code == 9 then
		Gamestate.switch(game)
	end
end

function game:enter()
	CONSTANTS.HOOYAH:stop()
	CONSTANTS.HOOYAH:play()
	love.audio.rewind()
	love.audio.resume()
	SUSHI_PLATE = love.graphics.newImage('img/sushi_plate.png')
	SUSHI_COUNTER = love.graphics.newImage('img/sushi_counter.png')
	TATAMI = love.graphics.newImage('img/tatami.png')
	KAMON = love.graphics.newImage('img/kamon.png')
	UI_MARGIN = 40

	genPart()

	--camera
	camShake = 0
	cam = Camera(love.graphics.getWidth()/2, love.graphics.getHeight()/2)

	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)
			world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	p1 = Player(1)
	p2 = Player(2)
	p1:setEnemy(p2)
	p2:setEnemy(p1)
	objSpawner = ObjSpawner()
	objSpawner:addSpawn(OBJ_TYPE.COIN, CONSTANTS.COIN_SPAWN_FREQUENCY, CONSTANTS.MAX_COINS_ON_SCREEN, nil)
	objSpawner:addSpawn(OBJ_TYPE.WASABI, CONSTANTS.WASABI_SPAWN_FREQUENCY, CONSTANTS.MAX_WASABI_ON_SCREEN, nil)
end

function game:update(dt)
	world:update(dt)
	partExplosion:update(dt)
	partSmoke:update(dt)
	partSparkle:update(dt)
	partWasabi:update(dt)
	p1:update(dt)
	p2:update(dt)
	objSpawner:update(dt)
	if camShake > 0 then
		cam:lookAt(love.window.getWidth()/2 + math.random(-1,1)*camShake*32, love.window.getHeight()/2 + math.random(-1,1)*camShake*32)
		camShake = camShake - dt
	else
		cam:lookAt(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
		camShake = 0
	end
end

function game:draw()
	cam:attach()
	-- for i = 0, 1 do
	-- 	for j = 0, 1 do
	-- 		love.graphics.draw(TATAMI, CONSTANTS.SCREEN_WIDTH/2-320+i*320, CONSTANTS.SCREEN_HEIGHT/2-240+j*240, 0, 2, 2)
	-- 	end
	-- end
	love.graphics.setColor(220, 60, 30)
	love.graphics.draw(KAMON, CONSTANTS.SCREEN_WIDTH/2, CONSTANTS.SCREEN_HEIGHT/2, 0, 3, 2, 77, 77)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(partWasabi)
	p1:draw()
	p2:draw()
	objSpawner:draw()

	love.graphics.draw(partSmoke)
	love.graphics.draw(partSparkle)
	love.graphics.setBlendMode('add')
	love.graphics.draw(partExplosion)
	love.graphics.setBlendMode('alpha')

	love.graphics.setColor(255, 255, 30)
	love.graphics.draw(SUSHI_PLATE, UI_MARGIN, CONSTANTS.SCREEN_HEIGHT -UI_MARGIN, 0, 2, 2, 0, 16)
	love.graphics.setColor(30, 255, 255)
	love.graphics.draw(SUSHI_PLATE, CONSTANTS.SCREEN_WIDTH-UI_MARGIN, CONSTANTS.SCREEN_HEIGHT - UI_MARGIN, 0, 2, 2, 190, 16)
	love.graphics.setColor(255, 255, 255)

	for i = 0, p1:getCoins()-1 do
		local sushiX = UI_MARGIN+28+(i%10)*36
		local sushiY = CONSTANTS.SCREEN_HEIGHT-UI_MARGIN-12-math.floor(i/10)*22
		love.graphics.draw(SUSHI_COUNTER, sushiX, sushiY, 0, 2, 2, 8, 24)
	end
	for i = 0, p2:getCoins()-1 do
		local sushiX = CONSTANTS.SCREEN_WIDTH-UI_MARGIN-28-(i%10)*36
		local sushiY = CONSTANTS.SCREEN_HEIGHT-UI_MARGIN-12-math.floor(i/10)*22
		love.graphics.draw(SUSHI_COUNTER, sushiX, sushiY, 0, 2, 2, 8, 24)
	end

	cam:detach()
end

-- function game:keypressed(key, code)
--     if key == 'p' then
--         return Gamestate.push(pause)
--     end
-- end

function game:joystickpressed(key, code)
	if code == 9 then
        return Gamestate.push(pause)
	end
end

function game:leave()
end

function pause:enter(from)
    self.from = from
    love.audio.pause()
end

function pause:draw()
    self.from:draw()
    love.graphics.setColor(0,0,0, 100)
    love.graphics.rectangle('fill', 0,0, CONSTANTS.SCREEN_WIDTH,CONSTANTS.SCREEN_HEIGHT)
    love.graphics.setColor(255,255,255)
    love.graphics.printf('PAUSE', 0, CONSTANTS.SCREEN_HEIGHT/2, CONSTANTS.SCREEN_WIDTH, 'center')
end

-- function pause:keypressed(key)
--     if key == 'p' then
--         return Gamestate.pop()
--     end
-- end

function pause:joystickpressed(key, code)
	if code == 9 then
		love.audio.resume()
        return Gamestate.pop()
	end
end

function over:enter(to, message, from)
	CONSTANTS.HOOYAH:stop()
	CONSTANTS.HOOYAH:play()
	love.audio.pause()
	self.from = from
	self.message = message
    winTimer = 0.5
end

function over:update(dt)
	if winTimer > 0 then
		self.from:update(dt)
		winTimer = winTimer - dt
	else
		winTimer = 0
	end
end

function over:draw()
    self.from:draw()
    if winTimer == 0 then
	    love.graphics.setColor(0,0,0, 100)
	    love.graphics.rectangle('fill', 0,0, CONSTANTS.SCREEN_WIDTH,CONSTANTS.SCREEN_HEIGHT)
	    love.graphics.setColor(255,255,255)
	    love.graphics.printf(self.message, 0, CONSTANTS.SCREEN_HEIGHT*3/4, CONSTANTS.SCREEN_WIDTH, 'center')
    end
end

-- function over:keyreleased(key, code)
--     if key == 'enter' or key == 'return' then
--         Gamestate.switch(game)
--     end
-- end

function over:joystickreleased(key, code)
	if code == 9 then
        Gamestate.switch(menu)
	end
end

function love.load()
	math.randomseed(os.time())
	love.graphics.setNewFont('assets/babyblue.ttf', 32)
	love.graphics.setBackgroundColor(60, 40, 30)
	love.audio.pause()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.keypressed(key)
	if key == 'escape' then
    	love.event.push('quit')
    end
end

function genPart()
	local particleSprite = love.graphics.newImage('img/particle.png')
	partExplosion = love.graphics.newParticleSystem(particleSprite, 300)
	partExplosion:setAreaSpread('normal', 4, 0)
	partExplosion:setParticleLifetime(0, 1)
	partExplosion:setDirection(-math.pi / 2)
	partExplosion:setSpread(math.pi / 2)
	partExplosion:setSpeed(100, 500)
	partExplosion:setColors(255, 255, 255, 255, 255, 255, 0, 255, 255, 30, 0, 255, 255, 0, 0, 128)
	partExplosion:setSizes(2, 0)
	partExplosion:setLinearAcceleration(0, 500, 0, 1000)

	partSmoke = love.graphics.newParticleSystem(particleSprite, 300)
	partSmoke:setAreaSpread('normal', 4, 4)
	partSmoke:setParticleLifetime(0, 0.5)
	partSmoke:setSpread(math.pi * 2)
	partSmoke:setSpeed(0, 200)
	partSmoke:setColors(220, 220, 220, 255, 120, 120, 120, 255)
	partSmoke:setSizes(3, 0)

	partWasabi = love.graphics.newParticleSystem(particleSprite, 300)
	partWasabi:setAreaSpread('normal', 16, 16)
	partWasabi:setParticleLifetime(0, 0.5)
	partWasabi:setDirection(-math.pi/2)
	partWasabi:setSpread(math.pi/4)
	partWasabi:setSpeed(0, 200)
	partWasabi:setColors(160, 240, 80, 255, 40, 160, 30, 255, 30, 100, 40, 0)
	partWasabi:setSizes(2, 0)

	particleSprite = love.graphics.newImage('img/sparkle.png')
	partSparkle = love.graphics.newParticleSystem(particleSprite, 300)
	partSparkle:setAreaSpread('normal', 4, 4)
	partSparkle:setParticleLifetime(0, 0.5)
	partSparkle:setDirection(-math.pi / 2)
	partSparkle:setSpread(math.pi * 2)
	partSparkle:setSpeed(0, 400)
	partSparkle:setSizes(3, 1)
end

function beginContact(a, b, coll)
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()
	if userDataA.type == userDataB.type then return end
	local player
	local mine
	local coin
	local wasabi

	if userDataA.type == OBJ_TYPE.PLAYER then player = userDataA
	elseif userDataA.type == OBJ_TYPE.MINE then mine = userDataA
	elseif userDataA.type == OBJ_TYPE.COIN then coin = userDataA
	elseif userDataA.type == OBJ_TYPE.WASABI then wasabi = userDataA end

	if userDataB.type == OBJ_TYPE.PLAYER then player = userDataB
	elseif userDataB.type == OBJ_TYPE.MINE then mine = userDataB
	elseif userDataB.type == OBJ_TYPE.COIN then coin = userDataB
	elseif userDataB.type == OBJ_TYPE.WASABI then wasabi = userDataB end

	if player and mine then
		if player.id ~= mine.player.id then mine:explode(false) end
	elseif player and coin and not player:isSpiced() then
		if player:collectCoin(coin) >= CONSTANTS.MAX_COINS then
			local message = ""
		    if player.id == 1 then
		    	message = "YELLOW is the ultimate sushi ninja!"
		    else
		    	message = "BLUE is the ultimate sushi ninja!"
		    end
			Gamestate.switch(over, message, game)
		end
		objSpawner:deleteItem(coin)
	elseif player and wasabi then
		player:eatSpice(CONSTANTS.SPICED_DURATION)
		objSpawner:deleteItem(wasabi)
	end
end

function endContact(a, b, coll) end

function preSolve(a, b, coll) end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2) end
