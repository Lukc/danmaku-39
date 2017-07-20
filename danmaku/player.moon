
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

		-- metadata for UIs
		@name = arg.name or "???"
		@title = arg.title or "???"
		@mainAttackName = arg.mainAttackName or "???"
		@secondaryAttackName = arg.secondaryAttackName or "???"

		@grazeRadius = arg.grazeRadius or 16
		@speed = arg.speed or 4
		@focusSpeed = arg.focusSpeed or (@speed / 2)

		@itemAttractionSpeed = arg.itemAttractionSpeed or 4
		@itemAttractionRadius = arg.itemAttractionRadius or 32
		@itemBorderAttractionSpeed = arg.itemBorderAttractionSpeed or 10
		@itemCollectionBorder = 3/11

		@grazedBullets = {}
		@grazeDelay = arg.grazeDelay or 60
		@graze = 0

		@interCollisionDuration = arg.interCollisionDuration or 60
		@entitiesCollidedWith = {}

		@score = 0

		@power = arg.power or 0
		@maxPower = arg.maxPower or @power

		-- Invulnerability times and cooldowns for specific events.
		@dyingTime = arg.dyingTime or 60 * 3
		@bombingTime = arg.bombingTime or 60 * 5

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
		@lifeFragments = 0
		@bombFragments = 0
		@fragmentsPerLife = arg.fragmentsPerLife or 5
		@fragmentsPerBomb = arg.fragmentsPerBomb or 5
		@bombsPerLife = @bombs

		@onDeath = arg.death
		@onBomb = arg.bomb

	addPower: (amount) =>
		if amount > 0 and @power == @maxPower
			return false
		elseif amount < 0 and @power == 0
			return false

		@power += amount

		if @power < 0
			power = 0
		elseif @power > @maxPower
			@power = @maxPower

		true

	addFragment: (type) =>
		if type == "life"
			@lifeFragments += 1

			if @lifeFragments >= @fragmentsPerLife
				@lifeFragments = 0
				@lives += 1
		elseif type == "bomb"
			@bombFragments += 1

			if @bombFragments >= @fragmentsPerBomb
				@bombFragments = 0
				@bombs += 1

	draw: =>
		super\draw!

		love.graphics.setColor 255, 255, 0
		love.graphics.circle "line", @x, @y, @grazeRadius

	---
	-- Overwritten update function.
	update: =>
		@frame += 1

		for bullet, delay in pairs @grazedBullets
			if delay > 1
				@grazedBullets[bullet] -= 1
			else
				@grazedBullets[bullet] = nil

		for enemy, delay in pairs @entitiesCollidedWith
			if delay > 1
				@entitiesCollidedWith[enemy] -= 1
			else
				@entitiesCollidedWith[enemy] = nil

		speed = if @focusing
			@focusSpeed
		else
			@speed

		dx, dy = 0, 0

		if @movement.left
			dx -= @movement.left
		if @movement.right
			dx += @movement.right
		if @movement.up
			dy -= @movement.up
		if @movement.down
			dy += @movement.down

		dist = math.sqrt(dx^2 + dy^2)

		if dist != 0
			angle = math.atan2 dy, dx

			dx = speed * math.cos angle
			dy = speed * math.sin angle

		bombsAllowed = not @game.noBombs and not @game.pacific
		if @bombing and @bombs >= 1 and bombsAllowed
			if @bombingFrame == false
				-- FIXME: The player should be invulnerable during bombs.
				--        … or should it?
				@bombingFrame = 0

				unless @game.training
					@bombs -= 1

				if @onBomb
					@game\failSpellcard!

					@\onBomb!

		if @bombingFrame
			@bombingFrame += 1

			if @bombingFrame >= @bombingTime
				@bombingFrame = false

		if @firing and not @game.pacific
			if @firingFrame == false
				@firingFrame = 0
			else
				@firingFrame += 1
		else
			@firingFrame = false

		if @dying
			@dyingFrame += 1

			if @dyingFrame >= @dyingTime
				unless @game.training
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

	grazeBullet: (bullet) =>
		if @grazedBullets[bullet]
			return false
		else
			@grazedBullets[bullet] = @grazeDelay
			@graze += 1

	collides: (entity) =>
		if @entitiesCollidedWith[entity]
			return false

		super\collides entity

	inflictDamage: (...) =>
		if @bombingFrame or @dyingFrame != 0
			return false

		super\inflictDamage ...

	die: =>
		@game\failSpellcard!

		super\die!

	__tostring: => "<Player: frame #{@frame}, [#{@x}:#{@y}]>"

