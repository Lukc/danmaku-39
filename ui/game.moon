
{
	:Danmaku,
	:Entity,
	:Enemy,
	:Bullet,
	:Player,
	:Stage
} = require "danmaku"

-- Needed for configuration thingies.
data = require "data"

Menu = require "ui.tools.menu"

state = {
}

mainMenuItem = ->
	{
		label: "Main menu"
		onSelection: {
			{
				label: "Are you sure?"
			}
			{
				label: "No"
				onSelection: =>
					@\setItemsList @items.parent
			}
			{
				label: "Yes"
				onSelection: =>
					state.manager\setState require "ui.menu"
			}
		}
	}

gameOverMenu = ->
	Menu {
		font: state.menu.font
		{
			label: "Game over…"
		}
		mainMenuItem!
	}

victoryMenu = ->
	Menu {
		font: state.menu.font
		{
			label: "Victory!"
		}
		mainMenuItem!
	}

state.enter = (stage, players) =>
	@players = {}
	@paused = false
	@resuming = false

	unless @font
		@font = love.graphics.newFont 24

	@menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		{
			label: "Pause"
		}
		{
			label: "Resume"
			onImmediateSelection: =>
				state.resuming = @drawTime
			onSelection: =>
				state.resuming = false
				state.paused = false
		}
		mainMenuItem!
	}
	@danmaku = Danmaku
		stage: Stage stage

	-- FIXME: update their positions, based on players count
	for player in *players
		player.x = @danmaku.width / 2
		player.y = @danmaku.height * 5 / 6

		table.insert @players, @danmaku\addEntity Player player

	-- Mostly serves to print entity hitboxes.
	@danmaku.debug = false


state.draw = =>
	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@danmaku.x = x
	@danmaku.y = y

	if @paused
		c = if @resuming
			c = 127 + 127 * math.min 1, @menu.drawTime - @resuming
		else
			c = 255 - 127 * math.min 1, @paused
		love.graphics.setColor c, c, c
	else
		love.graphics.setColor 255, 255, 255

	@danmaku\draw!

	w = @danmaku.width

	love.graphics.setFont @font

	love.graphics.setColor 255, 255, 255
	love.graphics.print "#{love.timer.getFPS!} FPS", x + w + 10, y + 745
	love.graphics.print "#{#@danmaku.entities} entities", x + w + 10, y + 770

	love.graphics.print "Score", x + w + 10, y + 10
	love.graphics.print "#{@danmaku.score}", x + w + 255, y + 10

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

	box = if #@players > 2
		smallPlayerBox
	else
		normalPlayerBox

	for i, player in ipairs @players
		box\draw player, x + w + 5, y + 80 + (i - 1) * (box.height + 5)

	if state.paused
		@menu\draw!

state.update = (dt) =>
	if state.paused
		state.paused += dt

		x = (love.graphics.getWidth! - 1024) / 2
		y = (love.graphics.getHeight! - 800) / 2

		@menu.x = x + 50
		@menu.y = y + 300
		@menu\update dt
		return

	if @danmaku.endReached
		print "We reached the end."
		state.paused = 0

		@menu = victoryMenu!

	for i = 1, #@players
		for key in *{"left", "right", "up", "down"}
			@players[i].movement[key] = love.keyboard.isScancodeDown data.config.inputs[i][key]
		for key in *{"bombing", "firing", "focusing"}
			@players[i][key] = love.keyboard.isScancodeDown data.config.inputs[i][key]

	playersLeft = false
	for i, player in ipairs @players
		if not player.readyForRemoval
			playersLeft = true
			break

	unless playersLeft
		state.paused = 0

		@menu = gameOverMenu!

	@danmaku\update dt

state.keypressed = (key, ...) =>
	if state.paused
		-- Holy shit, this is the project’s hackiest hack. I think.
		if key == "escape" and @menu.items.selection == 1 and @menu.items[1].label == "Resume"
			@menu\keypressed "return"
		else
			@menu\keypressed key, ...
	elseif key == "escape"
		@menu.drawTime = 0

		unless state.paused
			state.paused = 0

state

