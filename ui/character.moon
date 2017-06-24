
Grid = require "ui.tools.grid"
Menu = require "ui.tools.menu"

data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
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
		:x, :y, :width, :height, :cursors
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
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
		w: (1024 - 30) / 2
		h: (800 - 30 - @grid.height) / 2
		{
			label: ""
			type: "selector"
			values: [variant.name for variant in *data.characterVariants]
			value: data.characterVariants[1].name
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
	unless @multiplayer
		character = @grid.cursors[1].selectedCell
		index = @grid.cursors[1].index

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
		if @selectedCharacters[i]
			@variantMenus[i]\update dt

state.draw = =>
	love.graphics.setFont @font

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@selectedCharacter = nil

	@grid\draw!

	width = 1024 / 2
	height = @grid.y + @grid.height

	for i, cursor in ipairs @grid.cursors
		X, Y = if @multiplayer
			switch i
				when 1
					10, 10
				when 2
					width, 10
				when 3
					10, height
				when 4
					width, height
		else
			r = @grid\getCellRectangle cursor.index
			width = r.w - 20

			r.x, r.y + @grid.height - 400 - 10

		X += x
		Y += y

		if @selectedCharacters[i]
			if @selectedVariants[i]
				key = data.config.inputs[i].firing
				love.graphics.setColor 255, 255, 255
				love.graphics.print "Press #{key} to start playing.",
					X, Y
			else
				with @variantMenus[i]
					.x = X
					.y = Y
					.width = width - 20
					.height = height

					\draw!
		else
			love.graphics.setColor 255, 255, 255
			hoveredCharacter = @grid.cells[cursor.index]
			love.graphics.print hoveredCharacter.name,
				X, Y

state.keypressed = (key, scanCode, ...) =>
	for i, cursor in ipairs @grid.cursors
		inputs = data.config.inputs[i]

		if scanCode == inputs.firing or data.isMenuInput scanCode, "select"
			if @selectedVariants[i]
				goToGame!
			elseif @selectedCharacters[i]
				if @variantMenus[i].selectedItem
					return

				@variantMenus[i]\select!
			else
				@grid\select i
		elseif scanCode == inputs.bombing or data.isMenuInput scanCode, "back"
			if @selectedVariants[i]
				@selectedVariants[i] = nil
			elseif @selectedCharacters[i]
				if @variantMenus[i].selectedItem
					-- Speeding things up.
					@variantMenus[i].selectionTime = math.huge
					return

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
		else
			for direction in *{"left", "up", "right", "down"}
				menuInput = data.isMenuInput scanCode, direction
				if inputs[direction] == scanCode or menuInput
					if @selectedVariants[i]
						false -- ignoring
					elseif @selectedCharacters[i]
						if @variantMenus[i].selectedItem
							return

						@variantMenus[i][direction] @variantMenus[i]
					else
						@grid[direction] @grid, i

state.gamepadpressed = (joystick, button) =>
	for i, cursor in ipairs @grid.cursors
		inputs = data.config.gamepadInputs[i]

		if button == inputs.firing
			if @selectedVariants[i]
				goToGame!
			elseif @selectedCharacters[i]
				if @variantMenus[i].selectedItem
					return

				@variantMenus[i]\select!
			else
				@grid\select i
		elseif button == inputs.bombing
			if @selectedVariants[i]
				@selectedVariants[i] = nil
			elseif @selectedCharacters[i]
				if @variantMenus[i].selectedItem
					-- Speeding things up.
					@variantMenus[i].selectionTime = math.huge
					return

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
		else
			for direction in *{"left", "up", "right", "down"}
				if inputs[direction] == button
					if @selectedVariants[i]
						false -- ignoring
					elseif @selectedCharacters[i]
						if @variantMenus[i].selectedItem
							return

						@variantMenus[i][direction] @variantMenus[i]
					else
						@grid[direction] @grid, i

state

