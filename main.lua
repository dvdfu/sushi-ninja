Player = require 'player'
ObjSpawner = require 'obj_spawner'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(40, 60, 80)
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	p1 = Player(1)
	p2 = Player(2)
	c = Controller(1)
	objSpawner = ObjSpawner()
	objSpawner:addSpawn('COIN', 3)
end

function love.update(dt)
	world:update(dt)
	p1:update(dt)
	p2:update(dt)
	objSpawner:update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
end

function love.draw()
	p1:draw()
	p2:draw()
	objSpawner:draw()
end

function beginContact(a, b, coll)
	local PLAYER_TYPE = 'PLAYER'
	local MINE_TYPE = 'MINE'
	local COIN_TYPE = 'COIN'
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()
	if userDataA.type == userDataB.type then return end
	local player
	local mine
	local coin

	if userDataA.type == PLAYER_TYPE then
		player = userDataA
	elseif userDataA.type == MINE_TYPE then
		mine = userDataA
	elseif userDataA.type == COIN_TYPE then
		coin = userDataA
	end

	if userDataB.type == PLAYER_TYPE then
		player = userDataB
	elseif userDataA.type == MINE_TYPE then
		mine = userDataB
	elseif userDataA.type == COIN_TYPE then
		coin = userDataB
	end

	if player and mine then
		if player.id ~= mine.player.id then
			print("PLAYER ", player.id, " TOUCHED ENEMY MINE ", mine.id)
			mine:explode()
		end
	elseif player and coin then
		player, coin = userDataA, userDataB
		player:collectCoin(coin)
	end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

end
