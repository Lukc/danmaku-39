
Grid = require "ui.tools.grid"

data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
}

state.enter = (stage, multiplayer, noReset) =>
	if noReset
		return

	@multiplayer = multiplayer

	@stage = stage
	@selection = 1

	@selectedPlayers = [false for i = 1, multiplayer and 4 or 1]

	@grids = {}
	for i = 1, multiplayer and 4 or 1
		local inputs, color
		width  = 1024
		height = 800
		x      = 0
		y      = 0

		if multiplayer
			width = (1024 - 40) / 2
			height = (800 - 40 - 120) / 2

			x, y = switch i
				when 1
					10, 10
				when 2
					width + 20, 10
				when 3
					10, height + 20 + 120
				when 4
					width + 20, height + 20 + 120

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

		@grids[i] = Grid
			:x, :y, :width, :height, :inputs
			cells: data.players
			columns: #data.players
			rows: 1
			selectionColor: color
			onSelection: =>
				unless state.multiplayer
					nextState = require "ui.game"
					state.manager\setState nextState,
						state.stage, {@selectedCell}
					return

				state.selectedPlayers[i] = @selectedCell
			onEscape: =>
				state.manager\setState require("ui.difficulty"), nil, true

	while #data.players / @grids[1].rows > 4
		@grids[1].column = math.ceil(@grids[1].columns / 2)
		@grids[1].rows *= 2

	for i = 2, #@grids
		@grids[i].rows    = @grids[1].rows
		@grids[i].columns = @grids[1].columns

state.update = (dt) =>
	unless @multiplayer
		character = @grids[1].selectedCell
		index = @grids[1].selection

		@grids[1].selectionColor = switch index
			when 1
				{255, 63, 63}
			when 2
				{63, 255, 63}
			when 3
				{63, 191, 255}

state.draw = =>
	love.graphics.setFont @font

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@selectedCharacter = nil

	for i = 1, #@grids
		if @selectedPlayers[i]
			love.graphics.print "#{@selectedPlayers[i].name}", @grids[i].x, @grids[i].y
		else
			@grids[i]\draw!

	unless @multiplayer
		-- The character that has focus within the grid.
		character = @grids[1].selectedCell

		if character
			r = @grids[1]\getCellRectangle @grids[1].selection
			with x = x + r.x + 10
				with y = y + r.y + r.h - 10 - 320
					love.graphics.setColor 255, 255, 255

					love.graphics.rectangle "line",
						x, y + 10, 320, 320

					love.graphics.print "#{character.name}",
						x + (320 - @font\getWidth character.name) / 2, y + 10
					love.graphics.print "#{character.title}",
						x + (320 - @font\getWidth character.title) / 2, y + 50

					love.graphics.print "#{character.mainAttackName}",
						x, y + 120
					love.graphics.print "#{character.secondaryAttackName}",
						x, y + 160
	else
		with y = y + @grids[1].height + 10
			hasPlayer = false
			for player in *@selectedPlayers
				if player
					hasPlayer = true
					break

			if hasPlayer
				inputsTable = {}

				for i = 1, 4
					if @selectedPlayers[i]
						table.insert inputsTable,
							data.config.inputs[i].firing

				inputsString = table.concat inputsTable, ", "
				text = "Press #{inputsString} to play"
				love.graphics.print text,
					x + (1024 - @font\getWidth text) / 2,
					y + (120 - @font\getHeight text) / 2 - 8

state.keypressed = (key, scanCode, ...) =>
	for i, grid in ipairs @grids
		unless @selectedPlayers[i]
			grid\keypressed key, scanCode, ...
			continue

		if scanCode == data.config.inputs[i].firing
			players = {}

			for i = 1, 4
				if @selectedPlayers[i]
					table.insert players, @selectedPlayers[i]

			nextState = require "ui.game"
			state.manager\setState nextState,
				state.stage, players

state

