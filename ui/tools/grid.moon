
data = require "data"

class
	new: (arg) =>
		arg or= {}

		@columns = arg.columns or 2
		@rows = arg.rows or 2
		@cells = arg.cells or do
			print "CAUTION: Grid created without cell: argument."
			{}

		for variable in *{"x", "y", "width", "height"}
			@[variable] = arg[variable] or 1

		@selectedCell = nil
		@selection = 1

		if arg.inputs
			@inputs =
				left:   arg.inputs.left   or "left"
				right:  arg.inputs.right  or "right"
				down:   arg.inputs.down   or "down"
				up:     arg.inputs.up     or "up"
				select: arg.inputs.select or "return"

		@drawCell = arg.drawCell or       ->

		@onSelection = arg.onSelection or ->
		@onEscape = arg.onEscape or       ->

		@selectionColor = arg.selectionColor or {255, 191, 127}

	getCellRectangle: (index) =>
		w = @width / @columns
		h = @height / @rows
		{
			x: @x + ((index - 1) % @columns) * w
			y: @y + (math.ceil(index / @columns) - 1) * h
			:w
			:h
		}

	draw: =>
		x = (love.graphics.getWidth! - 1024) / 2
		y = (love.graphics.getHeight! - 800) / 2

		@selectedCell = nil

		for index = 1, (@columns * @rows)
			cell = @cells[index]

			r = with @\getCellRectangle index
				.x += x
				.y += y

			@\drawCell r

			unless cell
				love.graphics.setColor 127, 127, 127, 63
				love.graphics.rectangle "fill", r.x, r.y, r.w, r.h

			love.graphics.setColor 255, 255, 255
			love.graphics.rectangle "line", r.x, r.y, r.w, r.h

			if @selection == index
				-- FIXME: This should maybe be done in an update! or something.
				if cell
					@selectedCell = cell

				love.graphics.setColor @selectionColor
				for j = 1.5, 4.5
					love.graphics.rectangle "line",
						r.x + j, r.y + j, r.w - 2*j, r.h - 2*j

	keypressed: (key, scanCode, ...) =>
		x = (@selection - 1) % @columns + 1
		y = math.floor((@selection - 1) / @columns) + 1

		getWidth = (y) ->
			if y <= math.floor(#@cells / @columns)
				@columns
			else
				(#@cells - 1) % @columns + 1

		getHeight = (x) ->
			h = math.floor(#@cells / @columns)
			if #@cells % @columns >= x
				h += 1
			h

		if @inputs
			if scanCode == "escape"
				@\onEscape!
			elseif scanCode == @inputs.select
				@\onSelection @selectedCell
			elseif scanCode == @inputs.down
				y = (y - 0) % getHeight(x) + 1
			elseif scanCode == @inputs.up
				y = (y - 2) % getHeight(x) + 1
			elseif scanCode == @inputs.left
				x = (x - 2) % getWidth(y) + 1
			elseif scanCode == @inputs.right
				x = (x - 0) % getWidth(y) + 1
		else
			if data.isMenuInput key, "back"
				@\onEscape!
			elseif data.isMenuInput key, "select"
				@\onSelection @selectedCell
			elseif data.isMenuInput key, "down"
				y = (y - 0) % getHeight(x) + 1
			elseif data.isMenuInput key, "up"
				y = (y - 2) % getHeight(x) + 1
			elseif data.isMenuInput key, "left"
				x = (x - 2) % getWidth(y) + 1
			elseif data.isMenuInput key, "right"
				x = (x - 0) % getWidth(y) + 1

		@selection = (y - 1) * @columns + (x - 1) + 1

