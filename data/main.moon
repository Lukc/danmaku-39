
{
	:Entity,
	:Enemy,
	:Bullet,
	:Player,
	:Item,
	:Stage,
	:Boss,
} = require "danmaku"

{:BigBullet, :SmallBullet} = require "data.bullets"
spellcards = require "data.spellcards"
items = require "data.items"

{:circle, :laser} = require "data.helpers"

titleFont = love.graphics.newFont 42
subtitleFont = love.graphics.newFont 24

boss = Boss {
	radius: 32
	x: 600 / 2
	y: 800 / 5
	name: "Mi~mi~midori"

	spellcards[1]
	spellcards[2]
	spellcards[3]
}

stage1 = Stage {
	title: "A Stage for Testers"
	subtitle: "Developers’ playground"

	drawTitle: =>
		if @frame <= 30
			c = 255 * (@frame - 30) / 30
			love.graphics.setColor 200, 200, 200, c
		elseif @frame >= 150
			c = 255 - 255 * (@frame - 150) / 30
			love.graphics.setColor 200, 200, 200, c
		else
			love.graphics.setColor 200, 200, 200

		love.graphics.setFont titleFont

		w = titleFont\getWidth @title
		h = titleFont\getHeight @title

		love.graphics.print @title,
			(@game.width - w) / 2,
			(@game.height - h) / 2

		love.graphics.setFont subtitleFont

		w2 = subtitleFont\getWidth @subtitle

		love.graphics.print @subtitle,
			(@game.width - w2) / 2,
			(@game.height + h) / 2

	drawBackground: =>
			-- No background for now.

	drawBossData: =>
		love.graphics.setColor 255, 255, 255
		love.graphics.print "#{@boss.name}, #{@boss.health}/#{@boss.maxHealth}", 20, 20

		spell = @boss.currentSpell
		if spell and spell.name
			love.graphics.print "#{spell.name}", 40,60

	update: =>
		if @frame % 4 == 0
			@\addEntity Bullet SmallBullet
				x: 0
				y: 0
				angle: math.pi / 3
				speed: 10
				color: {255, 0, 0}

				update: =>
					@\die! if @frame > 20

	[1]: =>
		@\addEntity Bullet
			hitbox: Entity.Rectangle
			w: 130
			h: 50
			x: @width * 4 / 5
			y: @height / 2
			angle: math.pi * 2 / 3
			speed: 0
			update: =>
				@angle += math.pi / 2400

		for i = -9, 9, 1
			@\addEntity items.point
				x: @width / 2 + 25 * i
				y: @height / 9 - 50

		for i = -16, 16, 1
			@\addEntity items.power
				x: @width / 2 + 25 * i
				y: @height / 9 + 50

		for i = 1, 9
			@\addEntity items.lifeFragment
				x: @width / 2 + 25 * i
				y: @height / 9 - 10 * i

		for i = 1, 9
			@\addEntity items.bombFragment
				x: @width / 2 - 25 * i
				y: @height / 9 - 10 * i

	[30]: =>
		lasers = {}

		@\addEntity Enemy {
			x: -30
			y: @height / 8
			angle: 0
			speed: 1.6
			radius: 20
			update: =>
				if @frame == 60
					bullet = laser {
						from: self,
						bullet: {
							w: 15
							h: 80
							update: =>
								@angle += math.pi / 256
						}
						duration: 240
					}

					for bullet in circle {from: self, :bullet, bullets: 5}
						table.insert lasers, @\fire bullet
		}

	[180]: =>
		@\addEntity boss
}

playerA = Player
	name: "Player A"
	title: "Ordinary explorator"
	mainAttackName: "Quick bullets"
	secondaryAttackName: "Big, slow bullets"
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

{
	name: "Core Data"
	bosses: {
		boss
	}
	stages: {
		stage1
	}
	spellcards: spellcards
	players: {playerA}
}

