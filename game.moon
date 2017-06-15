
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
		itemAttractionRadius: 36
		update: =>
			if @firingFrame and @firingFrame % 8 == 0
				for i = -1, 1, 2
					@\fire
						angle: -math.pi/2
						speed: 5
						x: @x + 8 * i
						y: @y - 5
						radius: 3
		bomb: (game) =>
			@game\clearScreen!
		death: =>
			print "Lost a life, right about now."

	-- Mostly serves to print entity hitboxes.
	danmaku.debug = false


love.draw = ->
	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	danmaku.x = x
	danmaku.y = y
	danmaku\draw!

	w = danmaku.width

	love.graphics.setColor 255, 255, 255
	love.graphics.print "#{love.timer.getFPS!} FPS", x + w + 10, y + 10
	love.graphics.print "#{#danmaku.entities} entities", x + w + 10, y + 30

	for k, player in ipairs danmaku.players
		for i = 1, player.lives
			love.graphics.rectangle "line", x + w + 20 * i - 10, y + 20 + k * 40,
				15, 15
		for i = 1, player.bombs
			love.graphics.rectangle "line", x + w + 20 * i - 10, y + 40 + k * 40,
				15, 15

love.update = (dt) ->
	if danmaku.players[1]
		for key in *{"left", "right", "up", "down"}
			danmaku.players[1].movement[key] = love.keyboard.isDown key
		danmaku.players[1].bombing = love.keyboard.isDown "x"
		danmaku.players[1].firing = love.keyboard.isDown "y"
		danmaku.players[1].focusing = love.keyboard.isDown "lshift"
	else
		false -- Game over, duh.

	danmaku\update dt

