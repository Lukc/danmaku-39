
Grid = require "ui.tools.grid"

data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
	gridWidth: 1
	gridHeight: 3
}

state.enter = (stage, wantedPlayers, noReset) =>
	if noReset
		return

	-- This defines whether we’re doing single- or multiplayer.
	@wantedPlayers = wantedPlayers

	@stage = stage
	@selection = 1

	@selectedPlayers = [false for i = 1, wantedPlayers]

	@grids = {}
	for i = 1, wantedPlayers
		local inputs, color
		width  = 300
		height = 780
		x      = 10
		y      = 10

		if wantedPlayers > 1
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
			columns: 1
			rows: #data.players
			selectionColor: color
			onSelection: =>
				if @selectedCell
					if wantedPlayers == 1
						nextState = require "ui.difficulty"
						state.manager\setState nextState,
							state.stage, {@selectedCell}

					state.selectedPlayers[i] = @selectedCell
			onEscape: =>
				state.manager\setState require("ui.menu"), true

	while #data.players / @grids[1].columns > 4
		@grids[1].rows = math.ceil(@grids[1].rows / 2)
		@grids[1].columns *= 2

	for i = 2, #@grids
		@grids[i].rows    = @grids[1].rows
		@grids[i].columns = @grids[1].columns

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

	if @wantedPlayers == 1
		-- The character that has focus within the grid.
		character = @grids[1].selectedCell

		if character
			love.graphics.setColor 255, 255, 255

			love.graphics.rectangle "line",
				x + 1024 - 320 - 10, y + 10, 320, 780

			love.graphics.print "#{character.name}",
				x + 1024 - 320 + (320 - @font\getWidth character.name) / 2, y + 10
			love.graphics.print "#{character.title}",
				x + 1024 - 320 + (320 - @font\getWidth character.title) / 2, y + 50

			love.graphics.print "#{character.mainAttackName}",
				x + 1024 - 320, y + 120
			love.graphics.print "#{character.secondaryAttackName}",
				x + 1024 - 320, y + 160
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

			nextState = require "ui.difficulty"
			state.manager\setState nextState,
				state.stage, players

state

