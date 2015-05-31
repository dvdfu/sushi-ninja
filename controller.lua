Class = require 'lib.class'

Controller = Class {
	buffer = 0.1,
	init = function(self, i)
		self.num = i
		self.controller = love.joystick.getJoysticks()[i]
		if self.controller then
			_, self.rBumper = self.controller:getGamepadMapping('rightshoulder')
			_, self.lBumper = self.controller:getGamepadMapping('leftshoulder')
			_, self.start = self.controller:getGamepadMapping('start')
		end
	end
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

function Controller:start()
	if self.controller == nil then return false end
	return self.controller:isDown(self.start)
end

function Controller:RB()
	if self.controller == nil then return false end
	return self.controller:isDown(self.rBumper)
end

function Controller:LB()
	if self.controller == nil then return false end
	return self.controller:isDown(self.lBumper)
end

function Controller:RT()
	if self.controller == nil then return 0 end
	local r = self.controller:getGamepadAxis('triggerright') or 0
	if math.abs(r) > Controller.buffer then return r end
	return 0
end

function Controller:LT()
	if self.controller == nil then return 0 end
	local l = self.controller:getGamepadAxis('triggerleft') or 0
	if math.abs(l) > Controller.buffer then return l end
	return 0
end

function Controller:setVibrate(left, right, duration)
	if self.controller == nil then return end
	self.controller:setVibration(left,right,duration)
end

return Controller
