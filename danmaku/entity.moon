
class
	@Circle = 1
	@Rectangle = 2

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
		@angle = arg.angle or 0

		@health = arg.health or 1
		@maxHealth = @health

		@touchable = true

		@frame = 0

		@onUpdate = arg.update
		@onDraw = arg.draw or ->

		@dx, @dy = 0, 0

		@dying = false
		@dyingFrame = 0
		@dyingTime = 60 * 0.5
		@readyForRemoval = false

		@outOfScreenTime = 0

	draw: =>
		x = @x
		y = @y

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

			a1 = a + math.atan2(-h/2, -w/2)
			a2 = a + math.atan2(h/2, -w/2)
			a3 = a + math.atan2(h/2, w/2)
			a4 = a + math.atan2(-h/2, w/2)

			love.graphics.polygon "line",
				x + d * math.cos(a1), y + d * math.sin(a1),
				x + d * math.cos(a2), y + d * math.sin(a2),
				x + d * math.cos(a3), y + d * math.sin(a3),
				x + d * math.cos(a4), y + d * math.sin(a4)

		@\onDraw!

	update: =>
		dx = @speed * math.cos @angle
		dy = @speed * math.sin @angle

		-- That time should be greated for bosses, maybe even disabled completely.
		if @frame >= 60 * 60 * 5 and not @isPlayer
			@readyForRemoval = true

		if @dying
			@dyingFrame += 1

			if @dyingFrame >= @dyingTime
				@readyForRemoval = true
		else
			if @onUpdate
				@\onUpdate!

		@x += dx
		@y += dy

		if @hitboxType == @@Circle
			if @x + @radius < 0
				@outOfScreenTime += 1
			elseif @y + @radius < 0
				@outOfScreenTime += 1
			elseif @x - @radius > @game.width
				@outOfScreenTime += 1
			elseif @y - @radius > @game.height
				@outOfScreenTime += 1
		elseif @hitboxType == @@rectangle
			true -- FIXME: needs math here

		if @outOfScreenTime >= 30
			@readyForRemoval = true

		@frame += 1

	collides: (x, ...) =>
		unless @touchable
			return false
		unless x.touchable
			return false

		if @hitboxType == @@Circle and x.hitboxType == @@Circle
			dist = math.sqrt (x.x - @x)^2 + (x.y - @y)^2

			dist <= (x.radius + @radius)
		elseif @hitboxType == @@Rectangle and x.hitboxType == @@Circle
			center = do
				dx = x.x - @x
				dy = x.y - @y

				a = math.atan2(dy, dx)
				d = math.sqrt(dx^2 + dy^2)

				a -= @angle
				{
					x: math.cos(a) * d
					y: math.sin(a) * d
				}

			pointInRectangle = do
				-- First step is projecting the circle’s center on the 
				-- reference frame of the rectangle.

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

	inflictDamage: (amount, type) =>
		@health -= amount

		if @health <= 0
			@health = 0

			@dying = true
			@touchable = false

	__tostring: => "<Entity: frame #{@frame}>"

