
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

players = {}

love.load = ->
	local testBullet
	danmaku = Danmaku
		stage: data.stages[1]

	table.insert players, danmaku\addEntity Player
		name: "Meirusa"
		radius: 3
		x: danmaku.width / 2
		y: danmaku.height * 4 / 5
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

	for i = 2, 2
		table.insert players, danmaku\addEntity Player
			name: "Player #{i} test"
			x: 0
			y: 0
			lives: 999
			bombs: 999
			radius: 4

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
	love.graphics.print "#{love.timer.getFPS!} FPS", x + w + 10, y + 745
	love.graphics.print "#{#danmaku.entities} entities", x + w + 10, y + 770

	love.graphics.print "Score", x + w + 10, y + 10
	love.graphics.print "#{danmaku.score}", x + w + 255, y + 10

	love.graphics.print "Highscore", x + w + 10, y + 40
	love.graphics.print "HiScore here", x + w + 255, y + 40

	livesBox =
		height: 35
		width: 395
		draw: (player, x, y) =>
			love.graphics.setColor 255, 125, 1955
			for i = 0, 9
				if (i + 1) <= player.lives
					love.graphics.rectangle "line", x + 40 * i, y,
						35, 35

	bombsBox =
		height: 35
		width: 395
		draw: (player, x, y) =>
			love.graphics.setColor 127, 255, 127
			for i = 0, 9
				if (i + 1) <= player.bombs
					love.graphics.rectangle "line", x + 40 * i, y,
						35, 35

	normalPlayerBox =
		height: 260
		width: 405
		draw: (player, x, y) =>
			love.graphics.rectangle "line", x, y, @width, @height

			love.graphics.print "#{player.name}", x + 5, y + 5

			love.graphics.print "Score", x + 5, y + 45
			love.graphics.print "#{player.score}", x + 250, y + 45

			love.graphics.print "Points", x + 5, y + 75
			love.graphics.print "#{player.points}", x + 250, y + 75

			love.graphics.print "Graze", x + 5, y + 105
			love.graphics.print "#{player.graze}", x + 250, y + 105

			livesBox\draw player, x + 5, y + 140
			bombsBox\draw player, x + 5, y + 180

			love.graphics.setColor 255, 63, 63
			love.graphics.rectangle "line", 5 + x, 220 + y, 395 * (player.power / player.maxPower), 35
			love.graphics.print "#{player.power}/#{player.maxPower}", 5 + x, 225 + y

			love.graphics.setColor 255, 255, 255

	smallPlayerBox =
		height: 160
		width: 405
		draw: (player, x, y) =>
			love.graphics.rectangle "line", x, y, @width, @height

			love.graphics.print "#{player.name}", x + 5, y + 5
			love.graphics.print "#{player.score}", x + 250, y + 5

			livesBox\draw player, x + 5, y + 40
			bombsBox\draw player, x + 5, y + 80

			love.graphics.setColor 255, 63, 63
			love.graphics.rectangle "line", 5 + x, 120 + y, 245 * (player.power / player.maxPower), 35
			love.graphics.print "#{player.power}/#{player.maxPower}", 5 + x, 125 + y

			love.graphics.setColor 255, 255, 255
			love.graphics.print "#{player.graze}", 250 + x, 125 + y

			love.graphics.setColor 255, 255, 255

	box = if #players > 2
		smallPlayerBox
	else
		normalPlayerBox

	for i, player in ipairs players
		box\draw player, x + w + 5, y + 80 + (i - 1) * (box.height + 5)

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

