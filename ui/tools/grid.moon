
class
	new: (arg) =>
		arg or= {}

		@columns = arg.columns or 2
		@rows = arg.rows or 2
		@cells = arg.cells or do
			print "CAUTION: Grid created without cell: argument."
			{}

		@selectedCell = nil
		@selection = 1

		@drawCell = arg.drawCell or       ->

		@onSelection = arg.onSelection or ->
		@onEscape = arg.onEscape or       ->

	getCellRectangle: (index) =>
		w = 300 / @columns
		h = 780 / @rows
		{
			x: 10 + ((index - 1) % @columns) * w
			y: 10 + (math.ceil(index / @columns) - 1) * h
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

				love.graphics.setColor 255, 191, 127
				for j = 1.5, 4.5
					love.graphics.rectangle "line",
						r.x + j, r.y + j, r.w - 2*j, r.h - 2*j

	keypressed: (key, scancode, ...) =>
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
			print "h = #{h}"
			h

		if key == "escape"
			@\onEscape!
		elseif key == "return"
			@\onSelection @selectedCell
		elseif key == "down"
			y = (y - 0) % getHeight(x) + 1
		elseif key == "up"
			y = (y - 2) % getHeight(x) + 1
		elseif key == "left"
			x = (x - 2) % getWidth(y) + 1
		elseif key == "right"
			x = (x - 0) % getWidth(y) + 1

		@selection = (y - 1) * @columns + (x - 1) + 1

