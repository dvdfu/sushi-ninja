Class = require 'lib.class'
Vector = require 'lib.vector'

Mine = Class{
	KNOCK_BACK = 20,
	DANGER_PROXIMITY = 160,
	SUSHI_SPR = {
		love.graphics.newImage('img/sushi1.png'),
		love.graphics.newImage('img/sushi2.png'),
		love.graphics.newImage('img/sushi3.png')
	},
	EXPLOSION_SFX = love.audio.newSource("sfx/explosion.wav"),
	PLANT_SFX = love.audio.newSource("sfx/mine.wav"),

	init = function(self, id, x, y, player)
		self.type = OBJ_TYPE.MINE
		self.id = id
		self.pos = Vector(x, y)
		self.player = player

		self.body = love.physics.newBody(world, self.pos.x, self.pos.y, 'kinematic')
		self.shape = love.physics.newCircleShape(32)
		self.fixture = love.physics.newFixture(self.body, self.shape, 0)
		self.fixture:setUserData(self)
		self.fixture:setCategory(self.player.id)
		self.fixture:setMask(self.player.id)
		self.fixture:setSensor(true)
		self.sprite = Coin.SUSHI_SPR[math.random(#Coin.SUSHI_SPR)]
		Mine.PLANT_SFX:stop()
		Mine.PLANT_SFX:play()
	end
}

function Mine:update(dt)
end

function Mine:draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.draw(Coin.SHADOW_SPR, self.pos.x, self.pos.y+8, 0, 2, 2, 16, 16)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.sprite, self.pos.x, self.pos.y, 0, 2, 2, 16, 16)
end

function Mine:explode(silent)
	if not silent then
		camShake = 0.3
		Mine.EXPLOSION_SFX:stop()
		Mine.EXPLOSION_SFX:play()

		partExplosion:setPosition(self.pos:unpack())
		partExplosion:emit(40)
	end
	for key, mine in pairs(self.player.mines) do
		if key == self.id then
			local mine = table.remove(self.player.mines, key)

			if not silent then
				local diff = mine.pos - self.player.enemy.pos
				if diff:len() < Mine.DANGER_PROXIMITY then
					self.player.enemy.body:applyLinearImpulse(-diff.x*Mine.KNOCK_BACK,-diff.y*Mine.KNOCK_BACK)
					self.player.enemy.hurtTimer = 0.1
					self.player.enemy:stun()
				end
			end

			mine.body:destroy()
			self.player.minesCount = self.player.minesCount - 1
			for key, mine in pairs(self.player.mines) do mine:setId(key) end
			return
		end
	end
end

function Mine:setId(id) self.id = id end

return Mine
