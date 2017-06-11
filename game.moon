
{
	:Danmaku,
	:Entity,
	:Enemy,
	:Bullet,
	:Player,
	:Stage
} = require "danmaku"

data = require "data.main"

local danmaku

love.load = ->
	local testBullet
	danmaku = Danmaku
		stage: data.stages[1]

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

	-- Mostly serves to print entity hitboxes.
	danmaku.debug = false


love.draw = ->
	danmaku\draw!

	w = danmaku.width

	love.graphics.setColor 255, 255, 255
	love.graphics.print "#{love.timer.getFPS!} FPS", w + 10, 10
	love.graphics.print "#{#danmaku.entities} entities", w + 10, 30

love.update = (dt) ->
	for key in *{"left", "right", "up", "down"}
		danmaku.players[1].movement[key] = love.keyboard.isDown key
	danmaku.players[1].firing = love.keyboard.isDown "y"
	danmaku.players[1].focusing = love.keyboard.isDown "lshift"

	danmaku\update dt
