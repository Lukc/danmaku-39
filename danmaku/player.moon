
---
-- Class for playable entities.
--
-- It adds various fields to control the movement and behavior of the entity,
-- as well as checking that it will not leave the game screen.
--
-- Instances of `Player` also have a count of lives and bombs.
--
-- @classmod Player

Enemy = require "danmaku.enemy"

class extends Enemy
	new: (arg) =>
		arg or= {}

		super.__init self, arg

		@speed = arg.speed or 4
		@focusSpeed = arg.focusSpeed or (@speed / 2)

		@dyingTime = arg.dyingTime or 60 * 3
		@bombingTime = arg.bombingTime or 60

		@firingFrame = false -- boolean or positive integer
		@bombingFrame = false -- boolean or positive integer

		-- Controls.
		@movement =
			left: false
			right: false
			up: false
			down: false
		@firing = false
		@focusing = false
		@bombing = false

		@isPlayer = true

		@lives = arg.lives or 3
		@bombs = arg.bombs or 2
		@bombsPerLife = @bombs

		@onDeath = arg.death
		@onBomb = arg.bomb

	---
	-- Overwritten update function.
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

		if @bombing and @bombs >= 1
			if @bombingFrame == false
				-- FIXME: The player should be invulnerable during bombs.
				--        … or should it?
				@bombingFrame = 0
				@bombs -= 1

				if @onBomb
					@\onBomb!
			else
				@bombingFrame += 1
		else
			@bombingFrame = false

		if @bombingFrame and @bombingFrame >= @bombingTime
			@bombingFrame = false

		if @firing
			if @firingFrame == false
				@firingFrame = 0
			else
				@firingFrame += 1
		else
			@firingFrame = false

		if @dying
			@dyingFrame += 1

			if @dyingFrame >= @dyingTime
				@lives -= 1
				@bombs = @bombsPerLife

				if @lives <= 0
					-- FIXME: We may want to trigger.
					@readyForRemoval = true

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

