Class = require 'lib.class'

Controller = Class {
	init = function(self, i)
		self.num = i
		self.controller = love.joystick.getJoysticks()[i]
	end,
	buffer = 0.08
}

function Controller:LSX()
	if self.controller == nil then return 0 end
	local x = self.controller:getGamepadAxis('leftx') or 0
	if math.abs(x) > Controller.buffer then return x end
	return 0
end

function Controller:LSY()
	if self.controller == nil then return 0 end
	local y = self.controller:getGamepadAxis('lefty') or 0
	if math.abs(y) > Controller.buffer then return y end
	return 0
end

function Controller:RSX()
	if self.controller == nil then return 0 end
	local x = self.controller:getGamepadAxis('rightx') or 0
	if math.abs(x) > Controller.buffer then return x end
	return 0
end

function Controller:RSY()
	if self.controller == nil then return 0 end
	local y = self.controller:getGamepadAxis('righty') or 0
	if math.abs(y) > Controller.buffer then return y end
	return 0
end

return Controller