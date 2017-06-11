
Entity = require "danmaku.entity"
Bullet = require "danmaku.bullet"

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

	setBoss: (data) =>
		{
			:name,
			:lives
		} = data

		unless lives
			error "No lives count (:lives, integer) received."
		unless name
			error "No name (:name, string) received."

		@game.currentStage\setBoss
			entity: self
			:name
			:lives

	__tostring: => "<Enemy: frame #{@frame}>"

