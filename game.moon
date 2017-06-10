
Danmaku = require "danmaku"

Entity = require "entity"
Enemy = require "enemy"
Bullet = require "bullet"
Player = require "player"
Stage = require "stage"

local danmaku

love.load = ->
	danmaku = Danmaku
		stage: Stage {
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

			update: =>
				if @frame == 60
					@\addEntity Enemy
						radius: 7
						x: danmaku.width / 2
						y: danmaku.height / 5
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

							if (@frame % 20) == 0
								@\fire
									speed: 3
									radius: 3
									:draw

							if @frame == 1
								for i = 1, 800
									@\fire
										speed: 1 + math.random!
										angle: math.pi * 2 * math.random!
										radius: 3
										:draw
		}

	danmaku\addEntity Player
		radius: 3
		x: danmaku.width / 2
		y: danmaku.height * 4 / 5
		update: =>
			if @firingFrame and @firingFrame % 8 == 0
				for i = -1, 1, 2
					@\fire
						angle: -math.pi/2
						speed: 5
						x: @x + 8 * i
						y: @y - 5
						radius: 3


love.draw = ->
	love.graphics.setColor 255, 255, 255
	love.graphics.print "#{love.timer.getFPS!} FPS", 0, 0
	love.graphics.print "#{#danmaku.entities} entities", 0, 20
	danmaku\draw!

love.update = (dt) ->
	for key in *{"left", "right", "up", "down"}
		danmaku.players[1].movement[key] = love.keyboard.isDown key
	danmaku.players[1].firing = love.keyboard.isDown "y"
	danmaku.players[1].focusing = love.keyboard.isDown "lshift"

	danmaku\update dt


