
class
	new: (arg) =>
		arg or= {}

		@x = arg.x or 0
		@y = arg.y or 0

		@radius = arg.radius or 1

		@speed = arg.speed or 0
		@angle = arg.angle or 0

		@health = arg.health or 1
		@maxHealth = @health

		@touchable = true

		@frame = 0

		@onUpdate = arg.update

		@dx, @dy = 0, 0

		@dying = false
		@dyingFrame = 0
		@dyingTime = 60 * 0.5
		@readyForRemoval = false

	draw: (r) =>
		x = r.x + @x
		y = r.y + @y

		if @dying
			love.graphics.setColor 255, 0, 0
		else
			love.graphics.setColor 255, 255, 255

		love.graphics.circle "line", x, y, @radius

	update: =>
		@frame += 1

		dx = @speed * math.cos @angle
		dy = @speed * math.sin @angle

		if @frame >= 60 * 60 * 2 and not @isPlayer
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

	collides: (x, ...) =>
		unless @touchable
			return false
		unless x.touchable
			return false

		dist = math.sqrt (x.x - @x)^2 + (x.y - @y)^2

		dist <= (x.radius + @radius)

	inflictDamage: (amount, type) =>
		@health -= amount

		if @health <= 0
			@health = 0

			@dying = true
			@touchable = false

	__tostring: => "<Entity: frame #{@frame}>"

