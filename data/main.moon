
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

local testBullet
titleFont = love.graphics.newFont 42
subtitleFont = love.graphics.newFont 24
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
		testBullet = @\addEntity Bullet
			hitbox: Entity.Rectangle
			w: 130
			h: 50
			x: @width * 4 / 5
			y: @height / 2
			angle: math.pi * 2 / 3
			speed: 0
			update: =>
				@angle += math.pi / 2400

		sprite = love.graphics.newImage "data/art/item_test_point.png"
		@\addEntity Item
			radius: 4
			x: @width / 2
			y: @height / 9
			update: =>
				@y += 1
			draw: =>
				love.graphics.setColor 255, 255, 255
				love.graphics.circle "line", @x, @y, @radius
				love.graphics.draw sprite, @x - 16, @y - 16
			collection: =>
				print "Hey hey, item’s collected!"

	[120]: =>
		@\addEntity Boss {
			radius: 7
			x: @width / 2
			y: @height / 5
			name: "Mi~mi~midori"

			spellcards[1]
			spellcards[2]
		}
}

{
	stages: {
		stage1
	}
	spellcards: spellcards
}

