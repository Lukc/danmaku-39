
{
	:Entity,
	:Enemy,
	:Bullet,
	:Player,
	:Stage
} = require "danmaku"

local testBullet

{
	stages: {
		Stage {
			title: "A Stage for Testers"
			subtitle: "Developers’ playground"

			[10]: =>
				print "bleh~!"
				@\addEntity Bullet
					radius: 20
					x: 0
					y: 0
					angle: math.pi / 3
					speed: 2.5
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

			update: =>
				if @frame == 60
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
						update: =>
							if @frame == 0
								@\setBoss
									name: "???"
									lives: 999
							elseif @frame == 60
								@\setBoss
									name: "Mi~mi~midori~"
									lives: 42
							elseif @frame < 60
								return

							draw = =>
								if @dying
									c = 255 - (@dyingFrame / @dyingTime) * 255
									love.graphics.setColor 255, 255, 255, c
								else
									love.graphics.setColor 255, 255, 255

								love.graphics.circle "line", @x, @y, @radius + 2

							if @frame % 750 == 0
								for i = 1, 800
									local color

									@\fire
										speed: 0.1 + math.random! * 3
										angle: math.pi * 2 * math.random!
										radius: math.random 2, 15
										:draw
										draw: =>
											love.graphics.setColor color
											love.graphics.circle "line",
												@x, @y, @radius
										update: =>
											dist = math.sqrt 0 +
												(testBullet.x-@x)^2 +
												(testBullet.y-@y)^2
											collides = dist < 200 and
												@\collides testBullet

											if collides
												color = {63, 63, 255}
											else
												color = {255, 255, 255}
		}
	}
}

