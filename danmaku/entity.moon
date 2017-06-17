
---
-- Base class of an on-screen entity within a game of danmaku.
--
-- @see Enemy
-- @see Player
-- @see Bullet
--
-- @classmod Entity


class
	@Circle = 1     --- @field Entity.Circle
	@Rectangle = 2  --- @field Entity.Rectangle

	@distance = (a, b) ->
		math.sqrt (b.x - a.x)^2 + (b.y - a.y)^2

	---
	-- All parameters are optional and have sane default values.
	--
	-- @param arg {}
	-- @param arg.x Initial x-position of the entity.
	-- @param arg.y Initial y-position of the entity.
	-- @@param hitboxType Shape of the entity's hitbox.
	--  Can be `Circle` or `Rectangle`.
	-- @param arg.radius  Hitbox radius if it is a `Circle`.
	-- @param arg.width   Width of the hitbox if it is a `Rectangle`.
	-- @param arg.height  Height of the hitbox if it is a `Rectangle`.
	-- @param arg.speed   Speed of the entity.
	-- @param arg.angle   Direction the entity is moving towards.
	-- @param arg.health  Starting health and maximum health of the entity.
	-- @param arg.update  Code to execute each frame to update the entity.
	-- @param arg.draw Code to execute each frame to draw the entity.
	new: (arg) =>
		arg or= {}

		@x = arg.x or 0
		@y = arg.y or 0

		@hitboxType = arg.hitbox or @@Circle

		if @hitboxType == @@Circle
			@radius = arg.radius or 1
		elseif @hitboxType == @@Rectangle
			@width = arg.w or 1
			@height = arg.h or 1

		@speed = arg.speed or 0
		@angle = arg.angle or math.pi / 2
		@direction = arg.direction or arg.angle or math.pi / 2

		@health = arg.health or 1
		@maxHealth = @health

		@touchable =if arg.touchable != nil
			arg.touchable
		else
			true

		@damageable =if arg.damageable != nil
			arg.damageable
		else
			true

		@frame = 0

		@frameEvents = {}
		for key, value in pairs arg
			if type(key) == "number" and type(value) == "function"
				@frameEvents[key] = value

		@onUpdate = arg.update
		@onDraw = arg.draw

		@dx, @dy = 0, 0

		@dying = false
		@dyingFrame = 0
		@dyingTime = 60 * 0.5
		@readyForRemoval = false

		@outOfScreenTime = 0
		@disableTimeoutRemoval = false

	---
	-- Draws the entity.
	-- 
	-- Used internally.
	draw: =>
		x = @x
		y = @y

		if @game.debug or not @onDraw
			if @dying
				love.graphics.setColor 255, 0, 0
			else
				love.graphics.setColor 255, 255, 255

			if @hitboxType == @@Circle
				love.graphics.circle "line", x, y, @radius
			elseif @hitboxType == @@Rectangle
				w, h = @width, @height
				d = math.sqrt((w/2)^2 + (h/2)^2)
				a = @angle

				a1 = a + math.atan2(-w/2, -h/2)
				a2 = a + math.atan2(w/2, -h/2)
				a3 = a + math.atan2(w/2, h/2)
				a4 = a + math.atan2(-w/2, h/2)

				love.graphics.polygon "line",
					x + d * math.cos(a1), y + d * math.sin(a1),
					x + d * math.cos(a2), y + d * math.sin(a2),
					x + d * math.cos(a3), y + d * math.sin(a3),
					x + d * math.cos(a4), y + d * math.sin(a4)

		if @onDraw
			@\onDraw!

	---
	-- Updates the entity.
	--
	-- Its position is updated, its custom update code is executed, and
	-- the entity is marked as being ready to be removed if it's been out of
	-- screen for too long.
	update: =>
		@\doUpdate ->
			if @onUpdate
				@\onUpdate!

	---
	-- Used internally to update entities.
	--
	-- Its purpose is to be used by children classes.
	doUpdate: (onUpdate) =>
		dx = @speed * math.cos @direction
		dy = @speed * math.sin @direction

		-- That time should be greated for bosses, maybe even disabled completely.
		unless @disableTimeoutRemoval
			if @frame >= 60 * 60 * 5 and not @isPlayer
				@readyForRemoval = true

		if @dying
			@dyingFrame += 1

			if @dyingFrame >= @dyingTime
				@readyForRemoval = true
		else
			if @frameEvents[@frame]
				@frameEvents[@frame] self

			onUpdate self

		@x += dx
		@y += dy

		do
			-- FIXME: That stuff should be somehow configurable, even if it’s
			--        still a simple radius-based check.
			radius = if @hitboxType == @@Circle
				@radius
			elseif @hitboxType == @@Rectangle
				math.sqrt(@width^2 + @height^2)

			if @x + radius < 0
				@outOfScreenTime += 1
			elseif @y + radius < 0
				@outOfScreenTime += 1
			elseif @x - radius > @game.width
				@outOfScreenTime += 1
			elseif @y - radius > @game.height
				@outOfScreenTime += 1
			else
				@outOfScreenTime = 0

		if @outOfScreenTime >= 30
			@readyForRemoval = true

		@frame += 1

	---
	-- Returns whether two entities are colliding with one another or not.
	-- @param x Entity with which to check for collision.
	collides: (x) =>
		unless @touchable
			return false
		unless x.touchable
			return false

		if @hitboxType == @@Circle and x.hitboxType == @@Circle
			dist = math.sqrt (x.x - @x)^2 + (x.y - @y)^2

			dist <= (x.radius + @radius)
		elseif @hitboxType == @@Rectangle and x.hitboxType == @@Circle
			center = do
				-- First step is projecting the circle’s center on the 
				-- reference frame of the rectangle.

				dx = x.x - @x
				dy = x.y - @y

				a = math.atan2(dy, dx)
				d = math.sqrt(dx^2 + dy^2)

				a -= @angle
				{
					x: math.sin(a) * d
					y: math.cos(a) * d
				}

			pointInRectangle = do
				if center.x < -@width/2
					false
				elseif center.x > @width/2
					false
				elseif center.y < -@height/2
					false
				elseif center.y > @height/2
					false
				else
					true

			if pointInRectangle
				return true

			if center.y - x.radius < @height / 2 and
				center.y + x.radius > -@height / 2 and
				center.x - x.radius < @width / 2 and
				center.x + x.radius > -@width / 2

				-- We might be close to the corners and be recognized
				-- as colliding even though we’re not.
				-- This definitely deserves a FIXME.
				-- See https://i.stack.imgur.com/K6vRH.jpg
				-- It’s only an issue with entities large enough, but
				-- it’s still an issue.
				return true
			else
				return false
		elseif @hitboxType == @@Circle and x.hitboxType == @@Rectangle
			return x\collides self
		else
			print "Unimplemented collision detection (Rectangle/Rectangle)…"
			false -- FIXME: needs math here. We may not need it, though.

	---
	-- Damages the entity, and kills it if its health became 0.
	--
	-- Collision damage is usually of type `"collision"`.
	--
	-- @param amount Amount of health to remove.
	-- @param type Type of damage to inflict. It is ignored by default,
	--  but you can overwrite this method if you plan to have damages of
	--  different types and variable resistances.
	inflictDamage: (amount, type) =>
		unless @damageable
			return false

		@health -= amount

		if @health <= 0
			@\die!

	---
	-- Makes the entity untouchable and marks it as dying.
	die: =>
		@health = 0

		@dying = true
		@touchable = false

	angleToPlayer: =>
		players = @game.players

		unless #players > 0
			return math.pi/2, "no player"

		nearest = players[1]
		shortestDistance = @@.distance self, players[1]

		for i = 2, #players
			player = players[i]
			distance = @@.distance self, player

			if distance < shortestDistance
				shortestDistance = distance
				nearest = player

		return math.atan2 nearest.y - @y, nearest.x - @x

	__tostring: => "<Entity: frame #{@frame}>"

