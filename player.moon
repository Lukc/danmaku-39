
Enemy = require "enemy"

class extends Enemy
	new: (arg) =>
		arg or= {}

		super.__init self, arg

		@speed = arg.speed or 4
		@focusSpeed = arg.focusSpeed or (@speed / 2)

		@dyingTime = arg.dyingTime or 60 * 3

		@firingFrame = false

		-- Controls.
		@movement =
			left: false
			right: false
			up: false
			down: false
		@firing = false
		@focusing = false

		@isPlayer = true

	update: =>
		@frame += 1

		speed = if @focusing
			@focusSpeed
		else
			@speed

		dx, dy = 0, 0

		if @movement.left
			dx -= 1
		if @movement.right
			dx += 1
		if @movement.up
			dy -= 1
		if @movement.down
			dy += 1

		dx = speed * dx
		dy = speed * dy

		if dx != 0 and dy != 0
			hsr2 = math.sqrt(2) / 2

			dx *= hsr2
			dy *= hsr2

		if @firing
			if @firingFrame == false
				@firingFrame = -1

			@firingFrame += 1
		else
			@firingFrame = false

		if @dying
			@dyingFrame += 1

			if @dyingFrame >= @dyingTime
				-- FIXME: We’ll need the same code for bosses, right?
				@touchable = true
				@dyingFrame = 0
				@health = 1
				@dying = false

		if @onUpdate
			@\onUpdate!

		@x += dx
		@y += dy

		@x = math.max @x, @radius * 5
		@y = math.max @y, @radius * 5

		@x = math.min @x, @game.width - @radius * 5
		@y = math.min @y, @game.height - @radius * 5

	__tostring: => "<Player: frame #{@frame}, [#{@x}:#{@y}]>"

