
{
	:Entity,
} = require "danmaku"

{:newBullet, :BigBullet, :Curvy} = require "data.bullets"

{:CharacterData, :CharacterVariantData} = require "data.checks"

niceScreenCleaning = =>
	if @dyingFrame > 0
		radius = 100 - 75 * @dyingFrame / @dyingTime

		for bullet in *@game.bullets
			d = Entity.distance bullet, self

			if d <= radius
				bullet\die!

missileUpdate = (directionModifier) =>
	speedingSequence = 60 * 2

	if @frame <= speedingSequence
		@speed += 8/speedingSequence

		if @frame <= 60
			dx = directionModifier * (60 - @frame) / 60 / 3
			@x += dx

flameUpdate = (growthTime, radiusVariation) ->
	=>
		if @frame < growthTime
			@radius += radiusVariation
		else
			@radius -= radiusVariation

			if @radius <= 0
				@readyForRemoval = true

rifleSprite = require("images").get "bullet_player_rifle.png"

{
	CharacterData {
		name: "Best gurl"
		title: "Ordinary explorer"
		mainAttackName: "Quick bullets"
		bombsName: "Flying charms"
		secondaryAttackName: "FIXME: REMOVE"
		radius: 3
		itemAttractionRadius: 64
		update: =>
			niceScreenCleaning self
		bomb: (game) =>
			x, y = @x, @y
			radius = 6

			player = self

			for i = 1, 6
				angle = math.pi / 2 + math.pi * 2 / 6 * i
				@\fire newBullet
					overlaySprite: require("images").get "splash_bullet.png"
					defaultRadius: 160
					color: switch i
						when 1
							{255, 127, 127}
						when 2
							{255, 255, 127}
						when 3
							{127, 255, 127}
						when 4
							{127, 255, 255}
						when 5
							{127, 127, 255}
						when 6
							{255, 127, 255}
						else
							{255, 255, 255}
					spawnTime: 10
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
							player\fire newBullet
								overlaySprite: require("images").get "splash_bullet.png"
								defaultRadius: 191
								color: {255, 255, 255, 128}
								x: @x
								y: @y
								speed: 0
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
		bombsName: "Ancient spirits"
		secondaryAttackName: "FIXME: REMOVE"
		radius: 3
		itemAttractionRadius: 64
		update: =>
			niceScreenCleaning self
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

				@\fire newBullet
					overlaySprite: require("images").get "splash_bullet.png"
					defaultRadius: 160
					color: if i % 3 == 2
						{127, 255, 127}
					else
						{127, 191, 255}
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
								player\fire newBullet
									overlaySprite: require("images").get "bullet_curvy.png"
									defaultRadius: 64
									color: {255, 255, 255, 191}
									speed: 0
									x: @x
									y: @y
									radius: @radius
									spawnTime: 0
									health: 5
									update: =>
										@radius -= 0.3

										@angle = math.atan2 player.y - @y, player.x - @x

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
		title: "Dreaming inventor"
		mainAttackName: "Quick bullets"
		bombsName: "Fire bombs"
		secondaryAttackName: "FIXME: REMOVE"
		radius: 3
		itemAttractionRadius: 64
		update: =>
			niceScreenCleaning self
		bomb: (game) =>
			player = self

			controller = @\fire
				touchable: false
				update: =>
					@x = player.x
					@y = player.y

					if @frame % 4 == 0
						for i = -1, 1, 2
							player\fire newBullet
								overlaySprite: require("images").get "splash_bullet.png"
								defaultRadius: 160
								color: {255, 191, 63}
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
										if @color
											@color[3] += 0.5
											@color[2] -= 2

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
			name: "Magic Missiles"
			description: "Big, slow, and explosive. Explosions are simply the best."
			maxPower: 5 * 5
			update: =>
				-- FIXME: Make them *actually* explode.
				-- damage estimation: 10 * 2 / 8 + powerLevel * 6 / 48
				if @firingFrame and @firingFrame % 8 == 0
					for i = -1, 1, 2
						@\fire BigBullet
							spawnTime: 0
							angle: -math.pi/2
							speed: 12
							x: @x + 8 * i
							y: @y - 5
							radius: 3
							damage: 10

				powerLevel = math.floor(@power / 5)

				if @firingFrame and @firingFrame % 8 == 0
					for i = 1, powerLevel
						if @firingFrame % 48 != i * 8
							continue

						originAngle = math.pi * 2 / powerLevel * i + @frame * math.pi * 2 / 150
						originRadius = if @focusing
							30
						else
							14

						angleModifier = (originAngle % math.pi) * if @focusing
							1.5
						else
							0.75

						color = if @focusing
							{255, 160, 223}
						else
							{255, 91, 91}

						@\fire BigBullet
							spawnTime: 0
							angle: -math.pi / 2
							speed: 1.5
							x: @x + originRadius * math.cos originAngle
							y: @y + originRadius * math.sin originAngle
							radius: 7
							damage: 6
							color: color
							update: =>
								if @dying
									return

								missileUpdate self, angleModifier * if i == math.floor(0.5 + powerLevel / 2)
									0
								elseif i < powerLevel / 2
									-1
								else -- i > powerLevel / 2
									1

								if @frame % 6 == 1
									@player\fire BigBullet
										x: @x
										y: @y
										spawnTime: 0
										speed: @speed * 0.9
										direction: @direction
										radius: 7
										color: {
											color[1] - 32,
											color[2] - 32,
											color[3] - 32,
											127
										}
										update: =>
											@radius -= 7 / 40

											if @radius < 1
												@radius = 1
												@\die!
		}
		CharacterVariantData {
			name: "Rifle"
			description: "Bullets, bullets everywhere."
			maxPower: 5 * 5
			update: =>
				-- Damage estimation: 10 * 2 / 8 + powerLevel * 1 / 8
				if @firingFrame and @firingFrame % 5 == 0
					for i = -1, 1, 2
						@\fire BigBullet
							spawnTime: 0
							angle: -math.pi/2
							speed: 12
							x: @x + 8 * i
							y: @y - 5
							radius: 3
							damage: 10

					powerLevel = math.floor(@power / 5)

					radius = 32
					for i = 1, powerLevel
						k = (i - 1/2 - powerLevel/2)
						angle = math.pi * (1 / 2 + 1 / 5 * k)
						ox = radius * math.cos angle
						oy = radius * math.sin angle

						@\fire Curvy
							overlaySprite: rifleSprite
							spawnTime: 20
							angle: -math.pi / 2 + k * if @focusing
								math.pi / 2 / 64
							else
								-math.pi / 2 / 32
							speed: 12
							x: @x + ox
							y: @y + oy + 32
							radius: 7
							damage: 0.5
							color: switch i
								when 1
									{127, 255, 127}
								when 2
									{127, 255, 255}
								when 3
									{127, 191, 255}
								when 4
									{127, 127, 255}
								when 5
									{191, 127, 255}
								else
									{255, 255, 255}
		}
		CharacterVariantData {
			name: "Flamethrower"
			description: "Burning flames of love! The hotter it is, the less enemies you have!"
			maxPower: 5 * 5
			update: =>
				-- Damage estimation: 10 * 2 / 8 + 1 * powerLevel / 8
				if @firingFrame and @firingFrame % 8 == 0
					for i = -1, 1, 2
						@\fire BigBullet
							spawnTime: 0
							angle: -math.pi/2
							speed: 12
							x: @x + 8 * i
							y: @y - 5
							radius: 3
							damage: 10

					powerLevel = math.floor(@power / 5)

					radius = if @focusing
						48
					else
						64

					for i = 1, powerLevel
						k = (i - 1/2 - powerLevel/2)
						angle = math.pi * (1 / 2 + 1 / 5 * k)
						ox = radius * math.cos angle
						oy = radius * math.sin angle

						flameGrowthTime = 30 -
							4 * math.abs(i - 0.5 - powerLevel/2) +
							(@focusing and 10 or -4)

						@\fire BigBullet
							spawnTime: 0
							angle: -math.pi / 2 - k * math.pi / 2 / 32 * if @focusing
								-1
							else
								2
							speed: 6.5
							x: @x + ox
							y: @y + oy
							radius: 3
							damage: 1
							update: flameUpdate(flameGrowthTime, 1.5)
							color: if @focusing
								{127, 223, 255}
							else
								{127, 255, 191}
		}
	}
}

