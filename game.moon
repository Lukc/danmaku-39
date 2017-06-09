
Danmaku = require "danmaku"

Entity = require "entity"
Enemy = require "enemy"
Player = require "player"

local danmaku

love.load = ->
	danmaku = Danmaku!

	danmaku\addEntity Player
		radius: 2
		x: danmaku.width / 2
		y: danmaku.height * 4 / 5
		update: =>
			if @firingFrame and @firingFrame % 8 == 0
				@\fire
					angle: -math.pi/2
					speed: 5

	danmaku\addEntity Enemy
		x: danmaku.width / 2
		y: danmaku.height / 5
		update: =>
			if (@frame % 20) == 0
				@\fire
					speed: 3

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


