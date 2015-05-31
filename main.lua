love.graphics.setDefaultFilter('nearest', 'nearest')

Player = require 'player'
ObjSpawner = require 'obj_spawner'
Gamestate = require 'lib.gamestate'
CONSTANTS = require 'constants'
Controller = require 'controller'

local menu = {}
local game = {}
local pause = {}
local over = {}

function menu:enter()
    font = love.graphics.getFont()
    message = "Press START to play!"
end

function menu:draw()
    love.graphics.print(message, love.window.getWidth()/2 - font:getWidth(message)/2, love.window.getHeight()/2 - font:getHeight(message)/2)
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
	local particleSprite = love.graphics.newImage('img/particle.png')
	particles = love.graphics.newParticleSystem(particleSprite, 300)
	particles:setAreaSpread('normal', 30, 30)
	particles:setParticleLifetime(0.1, 0.7)
	particles:setDirection(-math.pi / 2)
	particles:setSpread(math.pi / 3)
	particles:setSpeed(0, 500)
	particles:setColors(255, 255, 255, 255, 255, 255, 0, 255, 255, 30, 0, 128)
	particles:setSizes(2, 0)
	-- particles:setLinearAcceleration(0, 0, 0, 1000)
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
	particles:update(dt)
	p1:update(dt)
	p2:update(dt)
	objSpawner:update(dt)
end

function game:draw()
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
	love.graphics.setBlendMode('additive')
	love.graphics.draw(particles)
	love.graphics.setBlendMode('alpha')
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
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    -- draw previous screen
    self.from:draw()
    -- overlay with pause message
    love.graphics.setColor(0,0,0, 100)
    love.graphics.rectangle('fill', 0,0, W,H)
    love.graphics.setColor(255,255,255)
    love.graphics.printf('PAUSE', 0, H/2, W, 'center')
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

function over:enter(to, winner)
    font = love.graphics.getFont()
    message = "Player " .. winner .. " is the ultimate sushi warrior!\nPress start to duel again."
end

function over:draw()
    love.graphics.print(message, love.window.getWidth()/2 - font:getWidth(message)/2, love.window.getHeight()/2 - font:getHeight(message)/2)
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
			Gamestate.switch(over, player.id)
		end
		objSpawner:deleteItem(coin)
	end
end

function endContact(a, b, coll) end

function preSolve(a, b, coll) end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2) end
