Class = require 'lib.class'
Vector = require 'lib.vector'
Timer = require 'lib.timer'
Coin = require 'coin'

ObjSpawner = Class {
	init = function(self, objType, spawnInterval, qty)
		math.randomseed(os.time())
		self.objType = objType
		self.objs = {}
		self.qty = qty
		self.spawnInterval = spawnInterval
		self.objSpawnerTimer = Timer.new()
		self.objSpawnerTimer.addPeriodic(self.spawnInterval, function() self:spawnObj() end, self.qty)
	end
}

function ObjSpawner:spawnObj()
	width, height = love.graphics.getDimensions()
	-- Place randomly on map
	widthRNG = math.random()
	heightRNG = math.random()
	objPos = Vector(width * widthRNG, height * heightRNG)
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
