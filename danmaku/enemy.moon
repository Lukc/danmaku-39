
---
-- Class of destructible entities within the game.
--
-- @classmod Enemy

Entity = require "danmaku.entity"
Bullet = require "danmaku.bullet"

class extends Entity
	new: (arg) =>
		arg or= {}

		Entity.__init self, arg

		@score = arg.score or 1

	setDefaultBulletValues: (bullet, data) =>
		bullet.x = data.x or @x
		bullet.y = data.y or @y

		bullet.angle = data.angle or math.pi / 2

	---
	-- Creates a Bullet and adds it to the game.
	--
	-- @param data Arguments passed to create the `Bullet`.
	fire: (data) =>
		bullet = if data.__class
			data
		else
			Bullet data

		@\setDefaultBulletValues bullet, data

		if @isPlayer
			bullet.player = self

		@game\addEntity bullet

		return bullet

	safeFire: (data) =>
		bullet = Bullet data

		@\setDefaultBulletValues bullet, data

		oldRadius = bullet.radius
		if data.safetyRadius
			bullet.radius = data.safetyRadius or bullet.radius * 1.5

		for player in *@game.players
			if player\collides bullet
				bullet.radius = oldRadius

				return nil, "collision avoided"

		bullet.radius = oldRadius

		@game\addEntity bullet

		return bullet

	__tostring: => "<Enemy: frame #{@frame}>"

