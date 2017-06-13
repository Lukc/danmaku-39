
---
-- Class of destructible entities within the game.
--
-- @classmod Enemy

Entity = require "danmaku.entity"
Bullet = require "danmaku.bullet"

class extends Entity
	---
	-- Creates a Bullet and adds it to the game.
	--
	-- @param data Arguments passed to create the `Bullet`.
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

