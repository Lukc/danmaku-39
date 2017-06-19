
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

	@grids = {}
	for i = 1, wantedPlayers
		local inputs
		width  = 300
		height = 780
		x      = 10
		y      = 10

		if wantedPlayers > 1
			width = (1024 - 40) / 2
			height = (800 - 40) / 2

			x, y = switch i
				when 1
					10, 10
				when 2
					width + 20, 10
				when 3
					10, height + 20
				when 4
					width + 20, height + 20

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
			onSelection: =>
				if @selectedCell
					nextState = require "ui.difficulty"
					state.manager\setState nextState,
						state.stage, {@selectedCell}
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

state.keypressed = (key, scancode, ...) =>
	for grid in *@grids
		grid\keypressed key, scancode, ...

state

