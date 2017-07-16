
Entity = require "danmaku.entity"
Player = require "danmaku.player"

class extends Entity
	new: (arg) =>
		arg or= {}

		Entity.__init self, arg

		unless arg.speed
			@speed = 2

		@normalSpeed = @speed

		-- Wether the GUI should try to put a marker below it or not.
		-- The GUI can put any truish value to identify the item type.
		@marker = arg.marker or false

		@onCollection = arg.collection or nil

	-- Items are entities that collide only with players.
	-- They also give them power, points or other advantages on collision,
	-- and tend to be attracted to players when close enough.
	collides: (player) =>
		if player.__class != Player
			return false

		distance = math.sqrt((player.x - @x)^2 + (player.y - @y)^2)

		return distance <= player.radius + @radius

	update: =>
		super\doUpdate ->
			attracted = false

			for player in *@game.players
				distance = math.sqrt((player.x - @x)^2 + (player.y - @y)^2)

				if distance <= player.itemAttractionRadius
					@direction = math.atan2 player.y - @y, player.x - @x

					@speed = player.itemAttractionSpeed or @speed

					attracted = true
					break

			unless attracted
				@direction = math.pi / 2
				@speed = @normalSpeed

	collected: (player) =>
		if @onCollection
			@\onCollection player

		@readyForRemoval = true

