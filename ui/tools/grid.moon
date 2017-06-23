
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

		@cursors = {}
		for cursor in *(arg.cursors or {{}})
			table.insert @cursors, {
				index: cursor.index or 1
				color: cursor.color or {255, 191, 127}
				inputs: {k,v for k,v in pairs cursor.inputs or {}}
				selectedCell: nil
			}

		with inputs = @cursors[1].inputs
			inputs.left =   inputs.left   or "left"
			inputs.right =  inputs.right  or "right"
			inputs.down =   inputs.down   or "down"
			inputs.up =     inputs.up     or "up"
			inputs.select = inputs.select or "return"

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

		for cursor in *@cursors
			cursor.selectedCell = nil

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

			cursorsHere = {}

			for cursor in *@cursors
				if cursor.index == index
					-- FIXME: This should maybe be done in an update! or
					--        something.
					table.insert cursorsHere, cursor
					cursor.selectedCell = cell

			for i, cursor in ipairs cursorsHere
				dx = (r.w + 50) / #cursorsHere

				oldScissor = {love.graphics.getScissor!}
				love.graphics.setScissor r.x, r.y, r.w, r.h

				love.graphics.setColor cursor.color
				love.graphics.polygon "fill",
					r.x +  0 + dx * (i - 1), r.y,
					r.x +  0 + dx * (i),     r.y,
					r.x - 50 + dx * (i),     r.y + r.h,
					r.x - 50 + dx * (i - 1), r.y + r.h

				love.graphics.setColor cursor.color
				for j = 1.5, 4.5
					love.graphics.rectangle "line",
						r.x + j, r.y + j, r.w - 2 * j, r.h - 2 * j

				love.graphics.setScissor unpack oldScissor

	keypressed: (key, scanCode, ...) =>
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

		for cursor in *@cursors
			x = (cursor.index - 1) % @columns + 1
			y = math.floor((cursor.index - 1) / @columns) + 1

			inputs = cursor.inputs

			if scanCode == "escape"
				@\onEscape!
			elseif scanCode == inputs.select
				@\onSelection cursor
			elseif scanCode == inputs.down
				y = (y - 0) % getHeight(x) + 1
			elseif scanCode == inputs.up
				y = (y - 2) % getHeight(x) + 1
			elseif scanCode == inputs.left
				x = (x - 2) % getWidth(y) + 1
			elseif scanCode == inputs.right
				x = (x - 0) % getWidth(y) + 1

			cursor.index = (y - 1) * @columns + (x - 1) + 1

