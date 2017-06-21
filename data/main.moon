 
{
	:Entity,
	:Enemy,
	:Bullet,
	:Item,
	:Stage,
	:Boss,
} = require "danmaku"

{:BigBullet, :SmallBullet} = require "data.bullets"
spellcards = require "data.spellcards"
items = require "data.items"
players = require "data.players"

{:circle, :laser} = require "data.helpers"

titleFont = love.graphics.newFont 42
subtitleFont = love.graphics.newFont 24

boss = {
	radius: 32
	x: 600 / 2
	y: 800 / 5
	name: "Mi~mi~midori"

	spellcards[1]
	spellcards[2]
	spellcards[3]
	spellcards[4]
	spellcards[5]
}

stage1 = {
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
		@\addEntity Boss boss
}

{
	name: "Core Data"
	bosses: {
		boss
	}
	stages: {
		stage1
	}
	spellcards: spellcards
	:players
}

