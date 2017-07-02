
Grid = require "ui.tools.grid"
Menu = require "ui.tools.menu"

data = require "data"
vscreen = require "vscreen"
fonts = require "fonts"

state = {
	font: love.graphics.newFont "data/fonts/Sniglet-Regular.otf", 24
	namesFont: love.graphics.newFont "data/fonts/Sniglet-Regular.otf", 24
}

goToGame = ->
	characters = {}
	for index, c in ipairs state.selectedCharacters
		if c
			character = {}

			for key, value in pairs c
				character[key] = value

			for key, value in pairs state.selectedVariants[index]
				character[key] = value

			-- Eheh. We’ll have to force a few settings to not
			-- be erased.
			character.name = c.name
			character.secondaryAttackName = state.selectedVariants[index].name

			table.insert characters, character

	nextState = require "ui.game"
	state.manager\setState nextState,
		state.options, characters

state.enter = (options, multiplayer, noReset) =>
	if noReset
		return

	@multiplayer = multiplayer

	@options = options
	@selection = 1

	@selectedVariants = {}
	@selectedCharacters = [false for i = 1, multiplayer and 4 or 1]

	local cursors
	width  = 1024
	height = 800
	x      = 0
	y      = 0

	if multiplayer
		cursors = {}
		width = 1024
		height = (800 - 40 - 120) / 2
		y = (800 - height - 20) / 2

		for i = 1, 4
			color = switch i
				when 1
					{255, 63,  63 }
				when 2
					{63,  127, 255}
				when 3
					{63,  255, 63 }
				when 4
					{255, 255, 63}

			inputs = {
				left:   data.config.inputs[i].left
				right:  data.config.inputs[i].right
				up:     data.config.inputs[i].up
				down:   data.config.inputs[i].down
				select: data.config.inputs[i].firing
			}

			table.insert cursors, {
				:index
				:color
				:inputs
			}

	@grid = Grid
		x: 0
		y: 0
		:width, :height, :cursors
		cells: data.characters
		columns: #data.characters
		rows: 1
		onSelection: (cursor) =>
			for i = 1, #@cursors
				if cursor != @cursors[i]
					continue

				state.selectedCharacters[i] = cursor.selectedCell

				for i = 1, 3
					cursor.color[i] += 64

				return
		onEscape: =>
			state.manager\setState require("ui.difficulty"), nil, true

	while #data.characters / @grid.rows > 4
		@grid.column = math.ceil(@grid.columns / 2)
		@grid.rows *= 2

	@variantMenus = [Menu {
		font: love.graphics.newFont "data/fonts/Sniglet-Regular.otf", 24
		w: (1024 - 30) / 2
		h: (800 - 30 - @grid.height) / 2
		{
			label: ""
			type: "selector"
			align: "center"
			values: [variant.name for variant in *data.characterVariants]
			value: data.characterVariants[1].name
			draw: =>
				r = @\getRectangle!

				alpha = @\getDefaultAlpha!

				variant = nil
				for v in *data.characterVariants
					if @value == v.name
						variant = v
						break

				do
					font = state.namesFont

					@menu\print @value,
						r.x + (r.w - font\getWidth @value) / 2,
						r.y,
						{255, 255, 255, alpha},
						font

				do
					font = @menu.font
					y = r.y + state.namesFont\getHeight!

					_, wrap = @menu.font\getWrap variant.description, @menu.width

					for line in *wrap
						@menu\print line,
							r.x + (r.w - font\getWidth line) / 2,
							y,
							{255, 255, 255, alpha},
							font

						y += font\getHeight!
			onSelection: (item) =>
				print "Variant selected for player #{i}."
				state.selectedVariants[i] = do
					variant = nil
					for v in *data.characterVariants
						if item.value == v.name
							variant = v
							break
					variant

				unless state.multiplayer
					goToGame!
		}
	} for i = 1, 4]

state.update = (dt) =>
	vscreen\update!

	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen.fullRectangle

	@font = fonts.get "Sniglet-Regular", 24 * sizemod
	@namesFont = fonts.get "Sniglet-Regular", 32 * sizemod

	if @multiplayer
		@grid.width = love.graphics.getWidth!
		@grid.height = love.graphics.getHeight! - 320 * sizemod
		@grid.x = 0
		@grid.y = (h - @grid.height) / 2
	else
		@grid.width = love.graphics.getWidth!
		@grid.height = love.graphics.getHeight!
		@grid.x = 0
		@grid.y = 0

		character = @grid.cursors[1].selectedCell
		index = @grid.cursors[1].index

		@variantMenus[1].width = (@grid.width / #@grid.cells)
		@variantMenus[1].items[1].x = (@grid.width / #@grid.cells) * (@grid.cursors[1].index - 1)
		@variantMenus[1].items[1].y = @grid.height - 80 * sizemod

		@grid.cursors[1].color = switch index
			when 1
				{255, 63, 63, 191}
			when 2
				{63, 255, 63, 191}
			when 3
				{63, 191, 255, 191}
			when 4
				{255, 255, 63, 191}
			when 5
				{255, 63, 191, 191}
			when 6
				{191, 255, 63, 191}

	for i, cursor in ipairs @grid.cursors
		@variantMenus[i].font = fonts.get "Sniglet-Regular", 24 * sizemod
		if @selectedCharacters[i]
			@variantMenus[i]\update dt

state.draw = =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen.fullRectangle

	font = @variantMenus[1].font
	love.graphics.setFont font

	@selectedCharacter = nil

	@grid\draw!

	-- FIXME: Rename this shit.
	width = @grid.width / 2 + 10 * sizemod
	height = @grid.y + @grid.height + 10 * sizemod

	for i, cursor in ipairs @grid.cursors
		X, Y = if @multiplayer
			switch i
				when 1
					10 * sizemod, 10 * sizemod
				when 2
					width, 10 * sizemod
				when 3
					10 * sizemod, height
				when 4
					width, height
		else
			r = @grid\getCellRectangle cursor.index
			width = r.w - 20

			r.x, r.y + @grid.height - 400 - 10

		if @selectedVariants[i]
			-- That state exists only during multiplayer.
			key = data.config.inputs[i].firing
			love.graphics.setColor 255, 255, 255
			love.graphics.print "Press #{key} to start playing.",
				X, Y + 50 * sizemod
		elseif @selectedCharacters[i]
			with @variantMenus[i]
				.x = X
				.y = Y
				.width = width - 10 * sizemod
				.height = height

				-- Oops. Our Menu API is obviously bugged.
				.items[1].y = .y

				\draw!
		else
			hoveredCharacter = @grid.cells[cursor.index]

			do
				text = hoveredCharacter.name or "???"
				font = @namesFont

				@variantMenus[1]\print text,
					X + (width - font\getWidth text) / 2, Y,
					{255, 255, 255},
					font

				Y += font\getHeight!

			do
				text = hoveredCharacter.title or "Undefined Fantastic Character"
				font = @variantMenus[1].font

				@variantMenus[1]\print text,
					X + (width - font\getWidth text) / 2, Y,
					{255, 255, 255, 223},
					font

				Y += font\getHeight!

			Y += font\getHeight! / 2

			do
				text = hoveredCharacter.mainAttackName or "???"
				font = @variantMenus[1].font

				@variantMenus[1]\print text,
					X + (width - font\getWidth text) / 2, Y,
					{255, 255, 255, 223},
					font

				Y += font\getHeight!

			do
				text = hoveredCharacter.bombsName or "???"
				font = @variantMenus[1].font

				@variantMenus[1]\print text,
					X + (width - font\getWidth text) / 2, Y,
					{255, 255, 255, 223},
					font

				Y += font\getHeight!

state.select = (i = 1) =>
	if @selectedVariants[i]
		goToGame!
	elseif @selectedCharacters[i]
		if @variantMenus[i].selectedItem
			return

		@variantMenus[i]\select!
	else
		@grid\select i

state.back = (i = 1) =>
	if @selectedVariants[i]
		@selectedVariants[i] = nil
	elseif @selectedCharacters[i]
		if @variantMenus[i].selectedItem
			-- Speeding things up.
			@variantMenus[i].selectionTime = math.huge
			return

		cursor = @grid.cursors[i]

		-- FIXME: Breach of OOP.
		@variantMenus[i].selectionTime = 0
		@variantMenus[i].selectedItem = {
			onSelection: =>
				state.selectedCharacters[i] = nil

				for i = 1, 3
					cursor.color[i] -= 64
		}
	else
		@grid\back!

state.direction = (direction, i = 1) =>
	if @selectedVariants[i]
		false -- ignoring
	elseif @selectedCharacters[i]
		if @variantMenus[i].selectedItem
			return

		@variantMenus[i][direction] @variantMenus[i]
	else
		@grid[direction] @grid, i

state.keypressed = (key, scanCode, ...) =>
	if #@grid.cursors == 1
		if data.isMenuInput scanCode, "select"
			@\select!
		elseif data.isMenuInput scanCode, "back"
			@\back!
		else
			for direction in *{"left", "up", "right", "down"}
				if menuInput = data.isMenuInput scanCode, direction
					@\direction direction, i
	else
		for i, cursor in ipairs @grid.cursors
			inputs = data.config.inputs[i]

			if scanCode == inputs.firing
				@\select i
			elseif scanCode == inputs.bombing
				@\back i
			else
				for direction in *{"left", "up", "right", "down"}
					if inputs[direction] == scanCode
						@\direction direction, i

state.gamepadpressed = (joystick, button) =>
	for i, cursor in ipairs @grid.cursors
		inputs = data.config.gamepadInputs[i]
		id = joystick\getID!
		
		unless inputs.gamepad == id
			continue

		if button == inputs.firing
			@\select i
		elseif button == inputs.bombing
			@\back i
		else
			for direction in *{"left", "up", "right", "down"}
				if inputs[direction] == button
					@\direction direction, i

state

