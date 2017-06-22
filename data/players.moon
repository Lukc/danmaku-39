
{
	:Entity,
} = require "danmaku"

missileUpdate = =>
	speedingSequence = 60 * 2

	if @frame <= speedingSequence
		@speed += 8/speedingSequence

		dx = @x - @player.x

		if dx == 0
			return

		sign = dx / math.abs(dx)

		if @frame <= 60
			dx = sign * (60 - @frame) / 60 / 3
			@x += dx

{
	{
		name: "Missiles"
		title: "Ordinary explorer"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "Big, slow bullets"
		radius: 3
		itemAttractionRadius: 64
		maxPower: 50
		update: =>
			-- damage estimation: 10 * 2 / 8 + powerLevel * 6 / 48
			if @firingFrame and @firingFrame % 8 == 0
				for i = -1, 1, 2
					@\fire
						angle: -math.pi/2
						speed: 12
						x: @x + 8 * i
						y: @y - 5
						radius: 3
						damage: 10

			if @firingFrame and @firingFrame % 48 == 0
				powerLevel = math.floor(@power / 10)

				for i = 1, powerLevel
					@\fire
						angle: -math.pi / 2
						speed: 1.5
						x: @x + (i - 1/2 - powerLevel/2) * 18
						y: @y + 24
						radius: 7
						damage: 6
						update: missileUpdate
		bomb: (game) =>
			x, y = @x, @y
			radius = 24

			for i = 1, 6
				angle = math.pi / 2 + math.pi * 2 / 6 * i
				@\fire
					damageable: false
					radius: 48
					update: =>
						@x = x + radius * math.cos angle
						@y = y + radius * math.sin angle

						radius = 64 * math.log((@frame + 60) / 60)
						angle += 0.065

						for bullet in *@game.bullets
							if bullet\collides self
								bullet\die!

						if @frame >= 60 * 5
							@\die!
		death: =>
			print "Lost a life, right about now."
	}
	{
		name: "Mirrors"
		title: "Ordinary explorer"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "Mirrors"
		radius: 3
		itemAttractionRadius: 64
		maxPower: 50
		update: =>
			if @firingFrame and @firingFrame % 8 == 0
				for i = -1, 1, 2
					@\fire
						angle: -math.pi/2
						speed: 6
						x: @x + 8 * i
						y: @y - 5
						radius: 3

				if @power > 10
					for i = -1, 1, 2
						@\fire
							angle: -math.pi/2 + math.pi / 128 * i
							speed: 4
							x: @x + 12 * i
							y: @y - 3
							radius: 7

				if @power > 20
					for i = -1, 1, 2
						@\fire
							angle: -math.pi/2 + math.pi / 32 * i
							speed: 4
							x: @x + 12 * i
							y: @y - 1
							radius: 7
		bomb: (game) =>
			@game\clearScreen!
		death: =>
			print "Lost a life, right about now."
	}
	{
		name: "Bullets++"
		title: "Ordinary explorer"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "More quick bullets"
		radius: 3
		itemAttractionRadius: 64
		maxPower: 50
		power: 30
		update: =>
			-- Damage estimation: 10 * 2 / 8 + powerLevel * 1 / 8
			if @firingFrame and @firingFrame % 8 == 0
				for i = -1, 1, 2
					@\fire
						angle: -math.pi/2
						speed: 12
						x: @x + 8 * i
						y: @y - 5
						radius: 3
						damage: 10

				powerLevel = math.floor(@power / 10)

				radius = 32
				for i = 1, powerLevel
					k = (i - 1/2 - powerLevel/2)
					angle = math.pi * (1 / 2 + 1 / 5 * k)
					ox = radius * math.cos angle
					oy = radius * math.sin angle
					@\fire
						angle: -math.pi / 2 + k * math.pi / 2 / 64
						speed: 12
						x: @x + ox
						y: @y + oy
						radius: 3
						damage: 1
		bomb: (game) =>
			@game\clearScreen!
		death: =>
			print "Lost a life, right about now."
	}
	{
		name: "Flamethrower"
		title: "Ordinary explorer"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "Burning flames of love!"
		radius: 3
		itemAttractionRadius: 64
		maxPower: 50
		power: 30
		update: =>
			-- Damage estimation: 10 * 2 / 8 + 1 * powerLevel / 8
			if @firingFrame and @firingFrame % 8 == 0
				for i = -1, 1, 2
					@\fire
						angle: -math.pi/2
						speed: 12
						x: @x + 8 * i
						y: @y - 5
						radius: 3
						damage: 10

				powerLevel = math.floor(@power / 10)

				radius = 48
				for i = 1, powerLevel
					k = (i - 1/2 - powerLevel/2)
					angle = math.pi * (-1 / 2 + 1 / 5 * k)
					ox = radius * math.cos angle
					oy = radius * math.sin angle
					@\fire
						angle: -math.pi / 2 - k * math.pi / 2 / 32
						speed: 6.5
						x: @x + ox
						y: @y + oy
						radius: 3
						damage: 1
						update: =>
							if @frame < 24
								@radius += 1.5
							else
								@radius -= 1.5

								if @radius <= 0
									@readyForRemoval = true
		bomb: (game) =>
			@game\clearScreen!
		death: =>
			print "Lost a life, right about now."
	}
}

