
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

	---
	-- Promotes the entity to boss status.
	--
	-- Bosses are likely displayed differently by the UI or the stage itself.
	-- Their health, name, and possibly other data are usually displayed.
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

