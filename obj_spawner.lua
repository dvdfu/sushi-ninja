Class = require 'lib.class'
Vector = require 'lib.vector'
Timer = require 'lib.timer'
Coin = require 'coin'

ObjSpawner = Class {
	init = function(self, objType, spawnInterval, qty)
		math.randomseed(os.time())
		self.xBound, self.yBound = love.graphics.getDimensions()
		self.objType = objType
		self.objs = {}
		self.qty = qty
		self.spawnInterval = spawnInterval
		self.objSpawnerTimer = Timer.new()
		self.objSpawnerTimer.addPeriodic(self.spawnInterval, function() self:spawnObj() end, self.qty)
	end
}

function ObjSpawner:spawnObj()
	-- Place randomly on map
	local xPos = math.random() * self.xBound
	local yPos = math.random() * self.yBound
	local objPos = Vector(xPos, yPos)
	-- Determine which object to create.
	if self.objType == Coin.objType then
		obj = Coin(objPos)
	else
		obj = 0
	end
	table.insert(self.objs, obj)
end

function ObjSpawner:update(dt)
	self.objSpawnerTimer.update(dt)
end

function ObjSpawner:draw()
	-- Draw spawned objects
	for k in pairs(self.objs) do
		if obj ~= 0 then
			self.objs[k]:draw()
		end
	end
end

return ObjSpawner
