Class = require 'lib.class'
Vector = require 'lib.vector'
Timer = require 'lib.timer'
Coin = require 'coin'

ObjSpawner = Class {
	init = function(self)
		math.randomseed(os.time())
		self.xBound, self.yBound = love.graphics.getDimensions()
		self.objsToSpawn = {}
		self.spawner = {}
		self.objSpawnerTimer = Timer.new()
	end
}

function ObjSpawner:addSpawn(objType, spawnInterval, qty)
	if self.objsToSpawn[objType] ~= nil then
		self:removeSpawn(objType)
	end
	self.objsToSpawn[objType] = {}
	self.spawner[objType] = self.objSpawnerTimer.addPeriodic(spawnInterval, function() self:spawnObj(objType) end, qty)
end

function ObjSpawner:removeSpawn(objType)
	self.objSpawnerTimer.cancel(spawner[objType])
end

function ObjSpawner:clear()
	self.objSpawnerTimer.clear()
end

function ObjSpawner:spawnObj(objType)
	-- Place randomly on map
	local xPos = math.random() * self.xBound
	local yPos = math.random() * self.yBound
	local objPos = Vector(xPos, yPos)
	-- Determine which object to create.
	if objType == Coin.OBJ_TYPE then
		obj = Coin(objPos)
	else
		obj = 0
	end
	table.insert(self.objsToSpawn[objType], obj)
end

function ObjSpawner:update(dt)
	self.objSpawnerTimer.update(dt)
end

function ObjSpawner:draw()
	-- Draw spawned objects
	for k, objs in pairs(self.objsToSpawn) do
		for l, obj in pairs(objs) do
			if obj ~= 0 then
				self.objsToSpawn[k][l]:draw()
			end
		end
	end
end

return ObjSpawner
