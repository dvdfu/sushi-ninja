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
		self.objsSpawned = {}
		self.objTableSizes = {}
		self.objTableMaxSizes = {}
		self.spawner = {}
		self.objSpawnerTimer = Timer.new()
	end
}

function ObjSpawner:addSpawn(objType, spawnInterval, maxQtyOnScreen, qty)
	if self.objsSpawned[objType] ~= nil then
		self:removeSpawn(objType)
	end
	if maxQtyOnScreen == nil then
		maxQtyOnScreen = CONSTANTS.DEFAULT_MAX_ITEMS_ON_SCREEN
	end
	self.objsSpawned[objType] = {}
	self.objTableSizes[objType] = 0
	self.objTableMaxSizes[objType] = maxQtyOnScreen
	self.spawner[objType] = self.objSpawnerTimer.addPeriodic(spawnInterval, function() self:spawnObj(objType) end, qty)
end

function ObjSpawner:removeSpawn(objType)
	self.objSpawnerTimer.cancel(spawner[objType])
end

function ObjSpawner:clearAll()
	for objType in self.objsSpawned do
		for objId in self.objsSpawned[objType] do
			if self.objsSpawned[objType][id] ~= 0 then
				self:deleteItem(self.objsSpawned[objType][id])
			end
		end
	end
	self.objsSpawned = nil
	self.objTableSizes = nil
	self.objTableMaxSizes = nil
	self.spawner = nil
	self.objSpawnerTimer.clear()
end

function ObjSpawner:spawnObj(objType)
	if self.objTableSizes[objType] ~= nil and self.objTableSizes[objType] >= self.objTableMaxSizes[objType] then return end
	local p1Pos, p2Pos = p1:getPos(), p2:getPos()

	local distToP = {}
	local objPos
	local objTooCloseToP = true
	while objTooCloseToP do
		objPos = self:genRandPos()
		-- Place randomly on map
		distToP[1] = math.abs((objPos - p1.pos):len2())
		distToP[2] = math.abs((objPos - p2.pos):len2())
		objTooCloseToP = false
		for pId, dist in pairs(distToP) do
			if dist < CONSTANTS.MIN_COIN_DIST2_FROM_PLAYER then
				objTooCloseToP = true
			end
		end
	end

	-- Determine which object to create.
	if objType == OBJ_TYPE.COIN then
		obj = Coin(objPos)
	else
		obj = 0
	end
	self.objsSpawned[objType][obj.id] = obj
	self.objTableSizes[objType] = self.objTableSizes[objType] + 1
end

function ObjSpawner:update(dt)
	self.objSpawnerTimer.update(dt)
	-- Update spawned objects
	for k, objs in pairs(self.objsSpawned) do
		for l, obj in pairs(objs) do
			if obj ~= 0 then
				self.objsSpawned[k][l]:update(dt)
			end
		end
	end
end

function ObjSpawner:draw()
	-- Draw spawned objects
	for k, objs in pairs(self.objsSpawned) do
		for l, obj in pairs(objs) do
			if obj ~= 0 then
				self.objsSpawned[k][l]:draw()
			end
		end
	end
end

-- Deletes a single item from a list of objects (e.g. coins)
function ObjSpawner:deleteItem(obj)
	objType = obj.type
	objId = obj.id
	obj:delete()
	if self.objsSpawned[objType] and self.objsSpawned[objType][objId] then
		self.objsSpawned[objType][objId] = 0
		self.objTableSizes[objType] = self.objTableSizes[objType] - 1
	end
end

function ObjSpawner:genRandPos()
	local xPos = math.random() * self.xBound + (CONSTANTS.X_MARGIN / 2)
	local yPos = math.random() * self.yBound + (CONSTANTS.Y_MARGIN / 2)
	return Vector(xPos, yPos)
end

return ObjSpawner
