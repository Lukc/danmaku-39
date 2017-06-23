
Grid = require "ui.tools.grid"

data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
}

state.enter = (options, multiplayer, noReset) =>
	if noReset
		return

	@multiplayer = multiplayer

	@options = options
	@selection = 1

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
		cells: data.players
		columns: #data.players
		rows: 1
		onSelection: (cursor) =>
			for i = 1, #@cursors
				if cursor != @cursors[i]
					continue

				unless state.multiplayer
					nextState = require "ui.game"
					state.manager\setState nextState,
						state.options, {cursor.selectedCell}
					return

				state.selectedCharacters[i] = cursor.selectedCell

				for i = 1, 3
					cursor.color[i] += 64

				return
		onEscape: =>
			state.manager\setState require("ui.difficulty"), nil, true

	while #data.players / @grid.rows > 4
		@grid.column = math.ceil(@grid.columns / 2)
		@grid.rows *= 2

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

state.draw = =>
	love.graphics.setFont @font

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@selectedCharacter = nil

	@grid\draw!

	if @multiplayer
		width = 1024 / 2 - 20
		height = (800 - @grid.height) / 2 - 20

		for i, cursor in ipairs @grid.cursors
			X, Y = switch i
				when 1
					10, 10
				when 2
					width + 20, 10
				when 3
					10, height + 20 + 120
				when 4
					width + 20, height + 20 + 120

			if @selectedCharacters[i]
				love.graphics.print @selectedCharacters[i].name,
					X, Y

state.keypressed = (key, scanCode, ...) =>
	for i, cursor in ipairs @grid.cursors
		if @selectedCharacters[i]
			if scanCode == data.config.inputs[i].firing
				print "Starting to play, duh~?"

				-- FIXME: Doesn’t work if a player hasn’t selected between
				--        two players who have. Mostly due to ui.game.

				characters = {}
				for character in *state.selectedCharacters
					if character
						table.insert characters, character

				nextState = require "ui.game"
				state.manager\setState nextState,
					state.options, characters
			elseif scanCode == data.config.inputs[i].bombing
				print "Unselecting character."

				@selectedCharacters[i] = nil

				for i = 1, 3
					cursor.color[i] -= 64
			else
				print "Not sure what else could possibly happen here."

			for _, input in pairs data.config.inputs[i]
				if input == scanCode
					return

	@grid\keypressed key, scanCode, ...

state

