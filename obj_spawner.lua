Class = require 'lib.class'
Vector = require 'lib.vector'
Timer = require 'lib.timer'

ObjSpawner = Class{
  init function(self, spawnInterval, qty, obj)
    math.randomseed(os.time())
    if qty == nil then
      qty = 1
    end
    self.objs = {}
    self.qty = qty
    self.spawnInterval = spawnInterval
    --Timer.addPeriodic(self.spawnInterval, function() self:spawnObj end, self.qty)
  end
}

function ObjSpawner:spawnObj()
  width, height = love.graphics.getDimensions()
  for i=1,qty+1 do
    widthRNG = math.random()
    heightRNG = math.random()
    objPos = Vector.new(width * widthRNG, height * heightRNG)
    coin = Coin.new()
    table.insert(self.objs, objPos)
  end
end

function ObjSpawner:update(dt)

end

function ObjSpawner:draw()
  -- Draw spawned objects
  for k in pairs(self.objs) do
    self.objs[k]:draw()
  end
end

return ObjSpawner
