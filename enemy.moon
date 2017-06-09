
Entity = require "entity"
Bullet = require "bullet"

class extends Entity
	fire: (data) =>
		bullet = Bullet data

		bullet.x = data.x or @x
		bullet.y = data.y or @y

		bullet.angle = data.angle or math.pi / 2

		if @isPlayer
			bullet.player = self

		@game\addEntity bullet

		return bullet

	__tostring: => "<Enemy: frame #{@frame}>"

