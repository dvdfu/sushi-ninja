Class = require 'lib.class'
Vector = require 'lib.vector'

Coin = Class{
  init function(self, pos)
    self.pos = pos
  end
}

function Coin:update(dt)

end

function Coin:draw()
  local r, g, b, a = love.graphics.getColor()
  -- Set draw to Yellow
  love.graphics.setColor(255, 255, 0, 1)
  love.graphics.circle('line', self.pos.x, self.pos.y, 5, 5)
  love.graphics.setColor(r, g, b, a)
end

return Coin
