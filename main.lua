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
	objSpawner:addSpawn('coin', 3)
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
	if a:getUserData().type == b:getUserData().type then end
	local player
	local mine
	if a:getUserData().type == "PLAYER" then
		player = a:getUserData()
		mine = b:getUserData()
	else
		player = b:getUserData()
		mine = a:getUserData()
	end
	if player.id ~= mine.player.id then
		print("PLAYER ", player.id, " TOUCHED ENEMY MINE ", mine.id)
		mine:explode()
	end
end
 
function endContact(a, b, coll)
 
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
 
end