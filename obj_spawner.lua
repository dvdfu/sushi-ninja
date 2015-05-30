Class = require 'lib.class'
Vector = require 'lib.vector'
Timer = require 'lib.timer'
Coin = require 'coin'

ObjSpawner = Class {
	init = function(self)
		math.randomseed(os.time())
		self.xBound, self.yBound = love.graphics.getDimensions()
		self.objsToSpawn = {}
		if self.objsToSpawn == nil then
			print('THIS IS NIL')
		end
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
	if objType == Coin.objType then
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
	for k in pairs(self.objsToSpawn) do
		for l in pairs(self.objsToSpawn[k]) do
			if obj ~= 0 then
				self.objsToSpawn[k][l]:draw()
			end
		end
	end
end

return ObjSpawner
