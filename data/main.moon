
{
	:Entity,
	:Enemy,
	:Bullet,
	:Player,
	:Stage
} = require "danmaku"

{:BigBullet, :SmallBullet} = require "data.bullets"

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
			angle: math.pi / 5
			x: @width * 4 / 5
			y: @height / 2
			angle: math.pi * 2 / 3
			speed: 0
			update: =>
				@angle += math.pi / 2400

	[60]: =>
		@\addEntity Enemy
			radius: 7
			x: @width / 2
			y: @height / 5

			draw: =>
				love.graphics.setColor 15, 255, 15
				love.graphics.circle "line", @x, @y, @radius + 6

				love.graphics.setColor 31, 255, 31
				love.graphics.circle "line", @x, @y, @radius + 8

				love.graphics.setColor 63, 255, 63
				love.graphics.circle "line", @x, @y, @radius + 10

			[0]: =>
				@\setBoss
					name: "???"
					lives: 999
			[60]: =>
				@\setBoss
					name: "Mi~mi~midori~"
					lives: 42

			update: =>
				if @frame < 60
					return

				draw = =>
					if @dying
						c = 255 - (@dyingFrame / @dyingTime) * 255
						love.graphics.setColor 255, 255, 255, c
					else
						love.graphics.setColor 255, 255, 255

					love.graphics.draw @x, @y
					love.graphics.circle "line", @x, @y, @radius + 2

				if @frame % 40 == 0
					for i = 1, 32
						@\fire BigBullet
							speed: 2.4
							angle: math.pi / 16 * i + (@frame / 60 * math.pi / 32)

							update: =>
								dist = math.sqrt 0 +
									(testBullet.x-@x)^2 +
									(testBullet.y-@y)^2
								collides = dist < 200 and
									@\collides testBullet

								if collides
									@color = {63, 255, 127}

				if @frame % 12 == 0
					for i = 1, 8
						@\fire SmallBullet
							speed: 3.6
							-- The “60” here is the start of the attacks.
							angle: math.pi / 4 * (i - 0.5) + math.sin (@frame - 60) / 90 * math.pi / 6
							color: {
								192 + 63 * math.sin(@frame / 60 + math.pi),
								96 + 31 * math.sin @frame / 60,
								192 + 63 * math.sin(@frame / 60),
							}
}

{
	stages: {
		stage1
	}
}

