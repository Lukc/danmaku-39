
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
						x: danmaku.width / 2
						y: danmaku.height / 5
						update: =>
							if (@frame % 20) == 0
								@\fire
									speed: 3
									radius: 3

							if @frame == 1
								for i = 1, 800
									@\fire
										speed: 1 + math.random!
										angle: math.pi * 2 * math.random!
										radius: 3
		}

	danmaku\addEntity Player
		radius: 3
		x: danmaku.width / 2
		y: danmaku.height * 4 / 5
		update: =>
			if @firingFrame and @firingFrame % 8 == 0
				@\fire
					angle: -math.pi/2
					speed: 5


love.draw = ->
	love.graphics.setColor 255, 255, 255
	love.graphics.print "#{love.timer.getFPS!}", 0, 0
	danmaku\draw!

love.update = (dt) ->
	for key in *{"left", "right", "up", "down"}
		danmaku.players[1].movement[key] = love.keyboard.isDown key
	danmaku.players[1].firing = love.keyboard.isDown "y"
	danmaku.players[1].focusing = love.keyboard.isDown "lshift"

	danmaku\update dt


