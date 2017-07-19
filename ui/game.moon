
{
	:Danmaku,
	:Entity,
	:Enemy,
	:Bullet,
	:Player,
	:Stage
} = require "danmaku"

utf8 = require "utf8"

-- Needed for configuration thingies.
data = require "data"
highscores = require "highscores"
vscreen = require "vscreen"
fonts = require "fonts"
images = require "images"

Menu = require "ui.tools.menu"
Grid = require "ui.tools.grid"

state = {
}

tryAgainItem = ->
	{
		label: "Restart"
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
					state\enter state.options, state.playerOptions
			}
		}
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
		tryAgainItem!
		mainMenuItem!
	}

victoryMenu = ->
	Menu {
		font: state.menu.font
		{
			label: "Victory!"
		}
		tryAgainItem!
		mainMenuItem!
	}

state.enter = (options, players) =>
	@players = {}
	@paused = false
	@awaitingPlayerName = false
	@resuming = false

	@playerName = data.config.lastUsedName

	@font = fonts.get nil, 24

	options or= {}
	{
		:noBombs, :pacific, :training, :difficulty
		:stage
	} = options

	@startingPower = options.startingPower or 0

	@options = options
	@playerOptions = players

	@stage = stage

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
		tryAgainItem!
		mainMenuItem!
	}
	@nameGrid = Grid {
		columns: 20
		rows: 8
		cells: {
			"a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
			"k", "l", "m", "n", "o", "p", "q", "r", "s", "t",

			"u", "v", "w", "x", "y", "z", "é", "è", "ê", "à",
			" ", " ", "*", "/", "+", "-", "<", ">", "[", "]",

			"A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
			"K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",

			"U", "V", "W", "X", "Y", "Z", "É", "È", "Ê", "À",
			".", ",", "’", ":", ";", "@", "#", "~", "(", ")",

			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

			" ", " ", " ", " ", " ", " ", " ", " ", " ", " ",

			" ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
			" ", " ", " ", " ", " ", " ", " ", " ", " ", "END",
		}
		cursors: {
			{
				color: {0, 0, 0}
			}
		}
		onSelection: (cursor) =>
			char = @cells[cursor.index]

			if char == "END"
				self = state

				highscores.save @stage, @players, @options, @danmaku.score, @playerName
				data.config.lastUsedName = @playerName
				data.saveConfig!

				@awaitingPlayerName = false
				@paused = 0
			else
				state.playerName ..= char
		onEscape: =>
			name = state.playerName
			offset = utf8.offset(name, -1)

			if offset
				state.playerName = string.sub(name, 1, offset - 1)
		drawCursor: =>
		drawCell: (r, grid) =>
			unless self
				self = " "

			if grid.cells[grid.cursors[1].index] == self
				love.graphics.setColor 255, 127, 127
			else
				love.graphics.setColor 255, 255, 255

			love.graphics.print (self or " "), r.x, r.y - 14
	}

	width, height = switch stage.screenRatio
		when "wide"
			1024, 600
		when "narrow"
			400,  800
		else
			640,  800

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

		with danmakuPlayer = @danmaku\addEntity Player player
			table.insert @players, danmakuPlayer

			danmakuPlayer.power = @startingPower

	@highscore = do
		if #players == 1
			highscores.get stage, players[1], options

	-- Mostly serves to print entity hitboxes.
	@danmaku.debug = false

state.draw = =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen\update!
	danmakuSizemod = state.danmaku.drawWidth / state.danmaku.width

	@danmaku.drawWidth = @danmaku.width * math.floor sizemod
	@danmaku.drawHeight = @danmaku.height * math.floor sizemod

	@danmaku.x = x + (w - @danmaku.drawWidth) / 2
	@danmaku.y = y + (h - @danmaku.drawHeight) / 2

	for item in *@danmaku.items
		if item.marker
			sprite = images.get "item_marker_" .. item.marker .. ".png"

			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite,
				@danmaku.x + item.x * danmakuSizemod,
				@danmaku.y + @danmaku.drawHeight,
				nil, nil, nil,
				sprite\getWidth!/2, sprite\getHeight!/2

	if @danmaku.boss
		boss = @danmaku.boss

		font = fonts.get "Sniglet-Regular", 18
		w = font\getWidth "Boss"

		c = 223 + (256 - 223) * math.sin @danmaku.frame / 120 * math.pi

		love.graphics.setColor 255, 0, 0
		@menu\print "Boss",
			@danmaku.x + boss.x * danmakuSizemod - w/2,
			@danmaku.y + @danmaku.drawHeight - 1,
			{c, c - 96, c - 64},
			font

	if @paused or @awaitingPlayerName
		c = if @resuming
			c = 127 + 127 * math.min 1, @menu.drawTime - @resuming
		else
			c = 255 - 127 * math.min 1, @paused or 0
		love.graphics.setColor c, c, c
	else
		love.graphics.setColor 255, 255, 255

	do
		if #@players == 1
			-- FIXME: hardcoded braindamage
			sprite = images.get "portraits/Coactlicue.png"

			love.graphics.draw sprite,
				x + @danmaku.x / 2, y + h/2,
				nil,
				@danmaku.drawHeight / sprite\getHeight!, nil,
				sprite\getWidth!/2,
				sprite\getHeight!/2

		if @danmaku.boss
			-- FIXME: hardcoded braindamage
			sprite = images.get "portraits/Coactlicue.png"

			love.graphics.draw sprite,
				x + @danmaku.drawWidth + 3 * (@danmaku.x - x) / 2, y + h/2,
				nil,
				-@danmaku.drawHeight / sprite\getHeight!, @danmaku.drawHeight / sprite\getHeight!,
				sprite\getWidth!/2,
				sprite\getHeight!/2

	do
		-- Background cleaning.
		oldColor = {love.graphics.getColor!}
		love.graphics.setColor 0, 0, 0
		love.graphics.rectangle "fill",
			@danmaku.x, @danmaku.y,
			@danmaku.drawWidth, @danmaku.drawHeight
		love.graphics.setColor oldColor

	@danmaku\draw!

	do
		s = math.floor sizemod
		love.graphics.setFont fonts.get "Sniglet-Regular", 24 * s

		i = 1
		for player in *@players
			sprite = images.get "item_test_life.png"
			for j = 1, player.lives
				love.graphics.draw sprite,
					@danmaku.x + (j - 1) * 32,
					@danmaku.y + @danmaku.drawHeight - (i * 96 -  0) * s,
					nil,
					32 / sprite\getWidth!

			sprite = images.get "item_test_bomb.png"
			for j = 1, player.bombs
				love.graphics.draw sprite,
					@danmaku.x + (j - 1) * 32,
					@danmaku.y + @danmaku.drawHeight - (i * 96 - 32 + 2) * s,
					nil,
					32 / sprite\getWidth!

			sprite = images.get "item_test_power.png"
			for j = 1, player.power / 5
				love.graphics.draw sprite,
					@danmaku.x + (j - 1) * 32,
					@danmaku.y + @danmaku.drawHeight - (i * 96 - 64 + 4) * s,
					nil,
					32 / sprite\getWidth!

			i += 1

	if state.awaitingPlayerName
		love.graphics.print @playerName .. "_", @nameGrid.x, @nameGrid.y - 50

		@nameGrid\draw!
	if state.paused
		@menu\draw!

state.update = (dt) =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen\update!
	danmakuSizemod = state.danmaku.drawWidth / state.danmaku.width

	@font = fonts.get nil, 24 * sizemod

	if state.awaitingPlayerName
		@nameGrid.width = 520 * danmakuSizemod
		@nameGrid.height = 300 * danmakuSizemod
		@nameGrid.x = x + 25 * sizemod + 25 * danmakuSizemod
		@nameGrid.y = y + vscreen.height - @nameGrid.height - 25 * danmakuSizemod

		return
	elseif state.paused
		state.paused += dt

		@menu.width = 400 * danmakuSizemod
		@menu.itemHeight = 64 * danmakuSizemod
		@menu.font = fonts.get "miamanueva", 32 * danmakuSizemod
		@menu.x = @danmaku.x + 32 * danmakuSizemod
		@menu.y = @danmaku.y + 96 * danmakuSizemod
		@menu\update dt

		return

	if @danmaku.endReached
		state.awaitingPlayerName = true
		print "We reached the end."
		state.paused = 0

		@menu = victoryMenu!

		return

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
	if state.awaitingPlayerName
		@nameGrid\keypressed key, ...
	elseif state.paused
		if key == "escape"
			state.resuming = @menu.drawTime

			@menu.selectionTime = 0
			@menu.selectedItem = {
				onSelection: =>
					state.paused = false
					state.resuming = false
			}
		else
			@menu\keypressed key, ...
	elseif key == "escape"
		@menu.drawTime = 0

		unless state.paused
			state.paused = 0

state.gamepadpressed = (joystick, button) =>
	if state.awaitingPlayerName
		@nameGrid\gamepadpressed joystick, button
	elseif state.paused
		if button == "start"
			if state.danmaku.endReached
				return

			state.resuming = @menu.drawTime

			@menu.selectionTime = 0
			@menu.selectedItem = {
				onSelection: =>
					state.paused = false
					state.resuming = false
			}
		else
			@menu\gamepadpressed joystick, button
	elseif button == "start"
		@menu.drawTime = 0

		unless state.paused
			state.paused = 0

state

