Player = require 'player'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(45, 45, 45)

	p1 = Player(1)
end

function love.update(dt)
	p1:update(dt)
end

function love.draw()
	p1:draw()
end
