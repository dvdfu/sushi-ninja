Class = require 'lib.class'
Vector = require 'lib.vector'
Timer = require 'lib.timer'
Coin = require 'coin'

ObjSpawner = Class {
	init = function(self)
		width = CONSTANTS.SCREEN_WIDTH
		height = CONSTANTS.SCREEN_HEIGHT
		self.xBound = width - CONSTANTS.X_MARGIN
		self.yBound = height - CONSTANTS.Y_MARGIN
		self.objsToSpawn = {}
		self.objTableSizes = {}
		self.objTableMaxSizes = {}
		self.spawner = {}
		self.objSpawnerTimer = Timer.new()
	end
}

function ObjSpawner:addSpawn(objType, spawnInterval, maxQtyOnScreen, qty)
	if self.objsToSpawn[objType] ~= nil then
		self:removeSpawn(objType)
	end
	if maxQtyOnScreen == nil then
		maxQtyOnScreen = CONSTANTS.DEFAULT_MAX_ITEMS_ON_SCREEN
	end
	self.objsToSpawn[objType] = {}
	self.objTableSizes[objType] = 0
	self.objTableMaxSizes[objType] = maxQtyOnScreen
	self.spawner[objType] = self.objSpawnerTimer.addPeriodic(spawnInterval, function() self:spawnObj(objType) end, qty)
end

function ObjSpawner:removeSpawn(objType)
	self.objSpawnerTimer.cancel(spawner[objType])
end

function ObjSpawner:clearAll()
	self.objsToSpawn = nil
	self.objTableSizes = nil
	self.objTableMaxSizes = nil
	self.spawner = nil
	self.objSpawnerTimer.clear()
end

function ObjSpawner:spawnObj(objType)
	if self.objTableSizes[objType] ~= nil and self.objTableSizes[objType] >= self.objTableMaxSizes[objType] then return end
	-- Place randomly on map
	local xPos = math.random() * self.xBound + (CONSTANTS.X_MARGIN / 2)
	local yPos = math.random() * self.yBound + (CONSTANTS.Y_MARGIN / 2)
	local objPos = Vector(xPos, yPos)
	-- Determine which object to create.
	if objType == OBJ_TYPE.COIN then
		obj = Coin(objPos)
	else
		obj = 0
	end
	table.insert(self.objsToSpawn[objType], obj)
	self.objTableSizes[objType] = self.objTableSizes[objType] + 1
end

function ObjSpawner:update(dt)
	self.objSpawnerTimer.update(dt)
	-- Update spawned objects
	for k, objs in pairs(self.objsToSpawn) do
		for l, obj in pairs(objs) do
			if obj ~= 0 then
				self.objsToSpawn[k][l]:update(dt)
			end
		end
	end
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

-- Deletes a single item from a list of objects (e.g. coins)
function ObjSpawner:deleteItem(obj)
	objType = obj.type
	objId = obj.id
	obj:delete()
	if self.objsToSpawn[objType] and self.objsToSpawn[objType][objId] then
		self.objsToSpawn[objType][objId] = 0
		self.objTableSizes[objType] = self.objTableSizes[objType] - 1
	end
end
return ObjSpawner
