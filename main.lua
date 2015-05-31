love.graphics.setDefaultFilter('nearest', 'nearest')

Player = require 'player'
ObjSpawner = require 'obj_spawner'
Gamestate = require 'lib.gamestate'
CONSTANTS = require 'constants'
Controller = require 'controller'
Camera = require "lib.camera"

local menu = {}
local game = {}
local pause = {}
local over = {}

function menu:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.printf("Press START to play!", 0, CONSTANTS.SCREEN_HEIGHT/2, CONSTANTS.SCREEN_WIDTH, 'center')
end

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
	--particle generators
	local particleSprite = love.graphics.newImage('img/particle.png')
	partExplosion = love.graphics.newParticleSystem(particleSprite, 300)
	partExplosion:setAreaSpread('normal', 4, 4)
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

	particleSprite = love.graphics.newImage('img/sparkle.png')
	partSparkle = love.graphics.newParticleSystem(particleSprite, 300)
	partSparkle:setAreaSpread('normal', 4, 4)
	partSparkle:setParticleLifetime(0, 0.5)
	partSparkle:setDirection(-math.pi / 2)
	partSparkle:setSpread(math.pi * 2)
	partSparkle:setSpeed(0, 400)
	partSparkle:setSizes(3, 1)

	--camera
	camShake = 0
	cam = Camera(love.window.getWidth()/2, love.window.getHeight()/2)

	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	p1 = Player(1)
	p2 = Player(2)
	p1:setEnemy(p2)
	p2:setEnemy(p1)
	objSpawner = ObjSpawner()
	objSpawner:addSpawn(OBJ_TYPE.COIN, CONSTANTS.COIN_SPAWN_FREQUENCY, CONSTANTS.MAX_COINS_ON_SCREEN, nil)
end

function game:update(dt)
	world:update(dt)
	partExplosion:update(dt)
	partSmoke:update(dt)
	partSparkle:update(dt)
	p1:update(dt)
	p2:update(dt)
	objSpawner:update(dt)
	if camShake > 0 then
		cam:lookAt(love.window.getWidth()/2 + math.random(-1,1)*camShake*32, love.window.getHeight()/2 + math.random(-1,1)*camShake*32)
		camShake = camShake - dt
	else
		cam:lookAt(love.window.getWidth()/2, love.window.getHeight()/2)
		camShake = 0
	end
end

function game:draw()
	cam:attach()
	p1:draw()
	p2:draw()
	objSpawner:draw()

	-- Draw labels
	local playerCoins = {}
	playerCoins[1] = string.format(CONSTANTS.SCORE_LABEL, 1, p1:getCoins())
	playerCoins[2] = string.format(CONSTANTS.SCORE_LABEL, 2, p2:getCoins())
	for p_id, text in pairs(playerCoins) do
		love.graphics.print(text,
			CONSTANTS.X_MARGIN + ((p_id - 1) * CONSTANTS.SCREEN_WIDTH / 2),
			CONSTANTS.SCREEN_HEIGHT - CONSTANTS.Y_MARGIN)
	end
	love.graphics.draw(partSmoke)
	love.graphics.draw(partSparkle)
	love.graphics.setBlendMode('additive')
	love.graphics.draw(partExplosion)
	love.graphics.setBlendMode('alpha')
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

function game:remove()
	objSpawner:clearAll()
end

function pause:enter(from)
    self.from = from
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
        return Gamestate.pop()
	end
end

function over:enter(to, winner, from)
	self.from = from
    font = love.graphics.getFont()
    message = "Player " .. winner .. " is the ultimate sushi warrior!\nPress start to duel again."
end

function over:draw()
    self.from:draw()
    love.graphics.setColor(0,0,0, 100)
    love.graphics.rectangle('fill', 0,0, CONSTANTS.SCREEN_WIDTH,CONSTANTS.SCREEN_HEIGHT)
    love.graphics.setColor(255,255,255)
    love.graphics.printf(message, 0, CONSTANTS.SCREEN_HEIGHT/2, CONSTANTS.SCREEN_WIDTH, 'center')
end

-- function over:keyreleased(key, code)
--     if key == 'enter' or key == 'return' then
--         Gamestate.switch(game)
--     end
-- end

function over:joystickreleased(key, code)
	if code == 9 then
        Gamestate.switch(game)
	end
end

function love.load()
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(90, 80, 70)
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.keypressed(key)
	if key == 'escape' then
    	love.event.push('quit')
    end
end

function beginContact(a, b, coll)
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()
	if userDataA.type == userDataB.type then return end
	local player
	local mine
	local coin

	if userDataA.type == OBJ_TYPE.PLAYER then player = userDataA
	elseif userDataA.type == OBJ_TYPE.MINE then mine = userDataA
	elseif userDataA.type == OBJ_TYPE.COIN then coin = userDataA end

	if userDataB.type == OBJ_TYPE.PLAYER then player = userDataB
	elseif userDataB.type == OBJ_TYPE.MINE then mine = userDataB
	elseif userDataB.type == OBJ_TYPE.COIN then coin = userDataB end

	if player and mine then
		if player.id ~= mine.player.id then mine:explode(false) end
	elseif player and coin then
		if player:collectCoin(coin) >= CONSTANTS.MAX_COINS then
			Gamestate.switch(over, player.id, game)
		end
		objSpawner:deleteItem(coin)
	end
end

function endContact(a, b, coll) end

function preSolve(a, b, coll) end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2) end
