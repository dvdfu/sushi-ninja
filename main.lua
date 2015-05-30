Player = require 'player'
Controller = require 'controller'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(45, 45, 45)

	p1 = Player(1)
	c = Controller(1)
end

function love.update(dt)
	p1:update(dt)
	-- print(love.joystick.getJoystickCount())
	print(c:LSX())
end

function love.draw()
	p1:draw()
end
