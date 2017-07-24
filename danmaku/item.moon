
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
		if @dying
			return false

		if player.__class != Player
			return false

		distance = math.sqrt((player.x - @x)^2 + (player.y - @y)^2)

		return distance <= player.radius + @radius

	update: =>
		players = {}

		super\doUpdate ->
			if not @dying
				nearest = false
				nearestDistance = math.huge
				nearestAttraction = nil

				for player in *@game.players
					distance = math.sqrt((player.x - @x)^2 + (player.y - @y)^2)

					attraction = if distance <= player.itemAttractionRadius
						"radius"
					elseif player.y <= @game.height * player.itemCollectionBorder
						"border"

					if attraction
						if not nearest or distance < nearestDistance
							nearest = player
							nearestDistance = distance
							nearestAttraction = attraction

				if nearest
					@direction = math.atan2 nearest.y - @y, nearest.x - @x
					@speed = if nearestAttraction == "radius"
						nearest.itemAttractionSpeed or @speed
					else
						nearest.itemBorderAttractionSpeed or @speed
				else
					@direction = math.pi / 2
					@speed = @normalSpeed

			if @onUpdate
				@\onUpdate!

	collected: (player) =>
		if @dying
			return

		if @onCollection
			@\onCollection player
		else
			@speed = 0
			@direction = -math.pi / 2

		@dying = true

