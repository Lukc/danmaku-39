
---
-- Class of destructible entities within the game.
--
-- @classmod Enemy

Entity = require "danmaku.entity"
Bullet = require "danmaku.bullet"

dist = (a, b) -> math.sqrt (b.x - a.x)^2 + (b.y - a.y)^2

class extends Entity
	new: (arg) =>
		arg or= {}

		Entity.__init self, arg

		@score = arg.score or 1

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

	angleToPlayer: =>
		players = @game.players

		unless #players > 0
			return math.pi/2, "no player"

		nearest = players[1]
		shortestDistance = dist self, players[1]

		for i = 2, #players
			player = players[i]
			distance = dist self, player

			if distance < shortestDistance
				shortestDistance = distance
				nearest = player

		return math.atan2 nearest.y - @x, nearest.x - @x

	__tostring: => "<Enemy: frame #{@frame}>"

