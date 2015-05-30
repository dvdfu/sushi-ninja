Player = require 'player'
ObjSpawner = require 'obj_spawner'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(40, 60, 80)
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)

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
