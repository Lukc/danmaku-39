
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
highscores = require "highscores"

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

state.enter = (options, players) =>
	@players = {}
	@paused = false
	@resuming = false

	options or= {}
	{
		:noBombs, :pacific, :training, :difficulty
		:stage
	} = options

	@options = options
	@stage = stage

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

	width, height = switch stage.screenRatio
		when "wide"
			974, 585
		when "narrow"
			375, 750
		else
			600, 750

	@danmaku = Danmaku
		x: 25
		y: 25
		stage: Stage stage
		:width, :height
		:noBombs, :pacific, :training, :difficulty

	-- FIXME: update their positions, based on players count
	for player in *players
		player.x = @danmaku.width / 2
		player.y = @danmaku.height * 5 / 6

		table.insert @players, @danmaku\addEntity Player player

	print stage.name, players[1].name, players[1].secondaryAttackName, options
	@highscore = do
		if #players == 1
			highscores.get stage, players[1], options

	-- Mostly serves to print entity hitboxes.
	@danmaku.debug = false

state.drawWideUI = (x, y) =>
	h = @danmaku.height + (@danmaku.y - y) * 2

	love.graphics.setFont @font

	for i = 1, #@players
		player = @players[i]

		r = with {
			w: (1024 - 25 - 25 * #@players) / #@players
			h: 800 - h - 25
			x: x + 25
			y: y + h
		}
			.x += (.w + 25) * (i - 1)

		love.graphics.setColor 255, 255, 255
		love.graphics.rectangle "line", r.x, r.y, r.w, r.h

		love.graphics.print "B: #{player.bombs}", r.x + 10, r.y + 10
		love.graphics.print "L: #{player.lives}", r.x + 10, r.y + 50
		love.graphics.print "S: #{player.score}", r.x + 10, r.y + 90

state.drawNormalUI = (x, y) =>
	w = @danmaku.width + (@danmaku.x - x) * 2

	love.graphics.setFont @font

	love.graphics.setColor 255, 255, 255
	love.graphics.print "#{love.timer.getFPS!} FPS", x + w + 10, y + 745
	love.graphics.print "#{#@danmaku.entities} entities", x + w + 10, y + 770

	love.graphics.print "Score", x + w + 10, y + 10
	love.graphics.print "#{@danmaku.score}", x + w + 255, y + 10

	love.graphics.print "Highscore", x + w + 10, y + 40
	love.graphics.print "#{math.max @highscore, @danmaku.score}", x + w + 255, y + 40

	local livesBox, bombsBox
	normalPlayerBox =
		height: 260
		width: 1024 - @danmaku.width - (@danmaku.x - x) * 2 - 25
		draw: (player, x, y) =>
			love.graphics.rectangle "line", x, y, @width, @height

			love.graphics.print "#{player.name}", x + 5, y + 5

			love.graphics.print "Score", x + 5, y + 45
			love.graphics.print "#{player.score}", x + 250, y + 45

			love.graphics.print "Points", x + 5, y + 75
			love.graphics.print "#{player.customData.points or 0}", x + 250, y + 75

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

	livesBox =
		height: 35
		width: box.width - 10
		draw: (player, x, y) =>
			love.graphics.setColor 255, 125, 1955
			for i = 0, 9
				if (i + 1) <= player.lives
					love.graphics.rectangle "line", x + 40 * i, y,
						35, 35

	bombsBox =
		height: 35
		width: box.width - 10
		draw: (player, x, y) =>
			love.graphics.setColor 127, 255, 127
			for i = 0, 9
				if (i + 1) <= player.bombs
					love.graphics.rectangle "line", x + 40 * i, y,
						35, 35

	for i, player in ipairs @players
		box\draw player, x + w + 5, y + 80 + (i - 1) * (box.height + 5)

state.draw = =>
	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@danmaku.x = x + 25
	@danmaku.y = y + 25

	if @paused
		c = if @resuming
			c = 127 + 127 * math.min 1, @menu.drawTime - @resuming
		else
			c = 255 - 127 * math.min 1, @paused
		love.graphics.setColor c, c, c
	else
		love.graphics.setColor 255, 255, 255

	-- XXX: Temporary markers.
	for item in *@danmaku.items
		if item.important
			love.graphics.setColor 255, 0, 0
			love.graphics.circle "fill",
				@danmaku.x + item.x, @danmaku.y + @danmaku.height,
				32

	-- XXX: Temporary markers.
	if @danmaku.boss
		boss = @danmaku.boss

		love.graphics.setColor 255, 0, 0
		love.graphics.circle "fill",
			@danmaku.x + boss.x, @danmaku.y + @danmaku.height,
			32

	love.graphics.setColor 255, 255, 255
	@danmaku\draw!

	if @danmaku.width >= 700
		@\drawWideUI x, y
	else
		@\drawNormalUI x, y

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

		highscores.save @stage, @players, @options, @danmaku.score, "???"

		@menu = victoryMenu!

	allJoysticks = love.joystick.getJoysticks!
	for i = 1, #@players
		inputs = data.config.inputs[i]
		padInputs = data.config.gamepadInputs[i]
		keyboard = (key) ->
			love.keyboard.isScancodeDown inputs[key]
		gamepad = (button) ->
			for joystick in *allJoysticks
				if joystick\getID! == padInputs.gamepad
					return joystick\isGamepadDown padInputs[button]

				return false

		-- Gamepad joysticks get priority, here.
		joystick = do
			joystick = nil
			for j in *allJoysticks
				if padInputs.gamepad == j\getID!
					joystick = j
					break
			joystick

		@players[i].movement.left = false
		@players[i].movement.right = false
		@players[i].movement.up = false
		@players[i].movement.down = false

		if joystick and joystick\getAxisCount! >= 1
			dx, dy = joystick\getAxes!

			if dx > 0
				@players[i].movement.right = dx
			elseif dx < 0
				@players[i].movement.left = -dx

			if dy > 0
				@players[i].movement.down = dy
			elseif dy < 0
				@players[i].movement.up = -dy

		for key in *{"left", "right", "up", "down"}
			@players[i].movement[key] or= (keyboard(key) or gamepad(key)) and 1

		for key in *{"bombing", "firing", "focusing"}
			@players[i][key] = keyboard(key) or gamepad(key)

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
			@menu\back!
		else
			@menu\keypressed key, ...
	elseif key == "escape"
		@menu.drawTime = 0

		unless state.paused
			state.paused = 0

state.gamepadpressed = (joystick, button) =>
	if state.paused
		if button == "start"
			@menu.selectionTime = 0
			@menu.selectedItem = {
				onSelection: =>
					state.paused = false
			}
		else
			@menu\gamepadpressed joystick, button
	elseif button == "start"
		@menu.drawTime = 0

		unless state.paused
			state.paused = 0

state

