
Grid = require "ui.tools.grid"

data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
	gridWidth: 1
	gridHeight: 3
}

getCharacterRectangle = (i) ->
	w = 300 / state.gridWidth
	h = 780 / state.gridHeight
	{
		x: 10 + ((i - 1) % state.gridWidth) * w
		y: 10 + (math.ceil(i / state.gridWidth) - 1) * h
		:w
		:h
	}

state.enter = (stage, noReset) =>
	if noReset
		return

	@stage = stage
	@selection = 1

	@grid = Grid
		cells: data.players
		columns: 1
		rows: #data.players
		onSelection: =>
			if @selectedCell
				state.manager\setState require("ui.difficulty"),
					state.stage, {@selectedCell}
		onEscape: =>
			state.manager\setState require("ui.menu"), true

	while #data.players / @grid.columns > 4
		@grid.rows = math.ceil(@grid.rows / 2)
		@grid.columns *= 2

state.draw = =>
	love.graphics.setFont @font

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@selectedCharacter = nil

	@grid\draw!

	-- The character that has focus within the grid.
	character = @grid.selectedCell

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
	@grid\keypressed key, scancode, ...

state

