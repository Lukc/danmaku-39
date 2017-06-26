
{
	:Entity,
} = require "danmaku"

{:CharacterData, :CharacterVariantData} = require "data.checks"

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

flameUpdate = (growthTime, radiusVariation) ->
	=>
		if @frame < growthTime
			@radius += radiusVariation
		else
			@radius -= radiusVariation

			if @radius <= 0
				@readyForRemoval = true

{
	CharacterData {
		name: "Best gurl"
		title: "Ordinary explorer"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "FIXME: REMOVE"
		radius: 3
		itemAttractionRadius: 64
		bomb: (game) =>
			x, y = @x, @y
			radius = 6

			player = self

			for i = 1, 6
				angle = math.pi / 2 + math.pi * 2 / 6 * i
				@\fire
					spawnTime: 0
					damageable: false
					radius: 48
					outOfScreenTime: math.huge
					update: =>
						@x = player.x + radius * math.cos angle
						@y = player.y + radius * math.sin angle

						with f = 60 + math.min @frame, 60 * 6
							radius = 64 * math.log(f / 60)
							angle += 0.065

						for bullet in *@game.bullets
							if bullet\collides self
								bullet\die!

						if @frame % 12 == 0
							player\fire
								x: @x
								y: @y
								radius: @radius
								health: 3 -- damageable, though not easily
								spawnTime: 0
								update: =>
									if @radius == 0
										return

									@radius -= 0.5

									if @radius <= 0
										@radius = 0
										@\die!

									for bullet in *@game.bullets
										if bullet\collides self
											bullet\die!

						if @frame >= 60 * 8
							@\die!
		death: =>
			print "Lost a life, right about now."
	}
	CharacterData {
		name: "Second best gurl"
		title: "Friendly tribal warrior"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "FIXME: REMOVE"
		radius: 3
		itemAttractionRadius: 64
		bomb: (game) =>
			player = self

			for i = 1, 9
				radius = if i % 3 == 2
					48
				else
					32
				angle = math.pi / 2 + math.pi * 2 / 9 * (i - 0.5)
				timeout = if i % 3 == 2
					60 * 4
				else
					60 * 6.5

				@\fire
					spawnTime: 0
					damageable: false
					:radius, :angle
					speed: 4
					update: =>
						@speed -= 1 / 19
						print @speed
						@speed = math.max 0, @speed

						@y -= @speed

						if @speed > 0
							if @frame % 5 == 0
								player\fire
									x: @x
									y: @y
									radius: @radius
									spawnTime: 0
									health: 5
									update: =>
										@radius -= 0.3

										if @radius <= 0
											@radius = 0
											@\die!

										for bullet in *@game.bullets
											if bullet\collides self
												bullet\die!

						for bullet in *@game.bullets
							if bullet\collides self
								bullet\die!

						if @frame >= timeout
							@\die!
		death: =>
			print "Lost a life, right about now."
	}
	CharacterData {
		name: "Needs-more-love gurl"
		title: "Simple navigator"
		mainAttackName: "Quick bullets"
		secondaryAttackName: "FIXME: REMOVE"
		radius: 3
		itemAttractionRadius: 64
		bomb: (game) =>
			player = self

			controller = @\fire
				touchable: false
				update: =>
					@x = player.x
					@y = player.y

					if @frame % 4 == 0
						for i = -1, 1, 2
							player\fire
								spawnTime: 0
								angle: i * math.pi / 2 + @frame / 4 * math.pi / 8
								speed: 4.5
								x: @x
								y: @y
								radius: 1
								damageable: false
								update: do
									flame = flameUpdate(30, 2)
									=>
										for bullet in *@game.bullets
											if bullet\collides self
												bullet\die!

										flame self

					if @frame == 60 * 5
						@\die!
		death: =>
			print "Lost a life, right about now."
	}
	variants: {
		CharacterVariantData {
			name: "Missiles"
			description: "Big, slow, and dangerous."
			maxPower: 50
			update: =>
				-- damage estimation: 10 * 2 / 8 + powerLevel * 6 / 48
				if @firingFrame and @firingFrame % 8 == 0
					for i = -1, 1, 2
						@\fire
							spawnTime: 0
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
							spawnTime: 0
							angle: -math.pi / 2
							speed: 1.5
							x: @x + (i - 1/2 - powerLevel/2) * 18
							y: @y + 24
							radius: 7
							damage: 6
							update: missileUpdate
		}
		CharacterVariantData {
			name: "Sword and rifle"
			description: "Bullets, bullets everywhere."
			maxPower: 50
			update: =>
				-- Damage estimation: 10 * 2 / 8 + powerLevel * 1 / 8
				if @firingFrame and @firingFrame % 8 == 0
					for i = -1, 1, 2
						@\fire
							spawnTime: 0
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
							spawnTime: 0
							angle: -math.pi / 2 + k * math.pi / 2 / 64
							speed: 12
							x: @x + ox
							y: @y + oy
							radius: 3
							damage: 1
		}
		CharacterVariantData {
			name: "Flamethrower"
			description: "Burning flames of love!"
			maxPower: 50
			update: =>
				-- Damage estimation: 10 * 2 / 8 + 1 * powerLevel / 8
				if @firingFrame and @firingFrame % 8 == 0
					for i = -1, 1, 2
						@\fire
							spawnTime: 0
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
							spawnTime: 0
							angle: -math.pi / 2 - k * math.pi / 2 / 32
							speed: 6.5
							x: @x + ox
							y: @y + oy
							radius: 3
							damage: 1
							update: flameUpdate(24, 1.5)
		}
	}
}

