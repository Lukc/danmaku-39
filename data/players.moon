
{
	:Entity,
	:Player,
} = require "danmaku"

{
	Player
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

				if @firingFrame % 48 == 0
					for i = -1, 1, 2
						if @power >= 40
							@\fire
								angle: -math.pi/2 + math.pi / 128 * i
								speed: 1.5
								x: @x + 12 * i
								y: @y - 3
								radius: 12
								damage: 12
								update: missileUpdate
						elseif @power >= 10
							@\fire
								angle: -math.pi/2 + math.pi / 128 * i
								speed: 1.5
								x: @x + 12 * i
								y: @y - 3
								radius: 7
								damage: 6
								update: missileUpdate

				if @firingFrame % 48 == 16
					for i = -1, 1, 2
						if @power >= 50
							@\fire
								angle: -math.pi/2 + math.pi / 48 * i
								speed: 1.5
								x: @x + 12 * i
								y: @y - 1
								radius: 12
								damage: 12
								update: missileUpdate
						elseif @power >= 20
							@\fire
								angle: -math.pi/2 + math.pi / 48 * i
								speed: 1.5
								x: @x + 12 * i
								y: @y - 1
								radius: 7
								damage: 6
								update: missileUpdate

				if @firingFrame % 48 == 32
					if @power >= 30
						for i = -1, 1, 2
							@\fire
								angle: -math.pi/2 + math.pi / 32 * i
								speed: 1.5
								x: @x + 12 * i
								y: @y + 1
								radius: 7
								damage: 6
								update: missileUpdate
		bomb: (game) =>
			@game\clearScreen!
		death: =>
			print "Lost a life, right about now."

	Player
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

	Player
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
				for i = -powerLevel/2, powerLevel/2
					angle = math.pi * (1 / 2 + 1 / 5 * i)
					ox = radius * math.cos angle
					oy = radius * math.sin angle
					@\fire
						angle: -math.pi / 2 + i * math.pi / 2 / 64
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

