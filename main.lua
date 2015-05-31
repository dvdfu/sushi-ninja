Player = require 'player'
ObjSpawner = require 'obj_spawner'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(40, 60, 80)
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	OBJ_TYPE = {}
	OBJ_TYPE.PLAYER = 'PLAYER'
	OBJ_TYPE.MINE = 'MINE'
	OBJ_TYPE.COIN = 'COIN'

	p1 = Player(1)
	p2 = Player(2)
	c = Controller(1)
	objSpawner = ObjSpawner()
	objSpawner:addSpawn(OBJ_TYPE.COIN, 0.05)
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
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()
	if userDataA.type == userDataB.type then return end
	local player
	local mine
	local coin

	if userDataA.type == OBJ_TYPE.PLAYER then
		player = userDataA
	elseif userDataA.type == OBJ_TYPE.MINE then
		mine = userDataA
	elseif userDataA.type == OBJ_TYPE.COIN then
		coin = userDataA
	end

	if userDataB.type == OBJ_TYPE.PLAYER then
		player = userDataB
	elseif userDataB.type == OBJ_TYPE.MINE then
		mine = userDataB
	elseif userDataB.type == OBJ_TYPE.COIN then
		coin = userDataB
	end

	if player and mine then
		if player.id ~= mine.player.id then
			print("PLAYER ", player.id, " TOUCHED ENEMY MINE ", mine.id)
			mine:explode()
		end
	elseif player and coin then
		player:collectCoin(coin)
		objSpawner:deleteItem(coin)
	end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

end
