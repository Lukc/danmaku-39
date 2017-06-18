
class
	new: (arg) =>
		arg or= {}

		@font = arg.font
		@items = {
			selection: 1
		}
		@drawTime = 0

		@y = arg.y or 0
		@x = arg.x or 0

		@inputCatchMode = false

		for item in *arg
			table.insert @items, item

	isSelectable: (item) =>
		return item.onSelection or item.onInputCatch

	setItemsList: (target) =>
		unless target.parent or target == @items.parent
			target.parent = @items

		@items = target
		@drawTime = 0

		if @items.maxItemsDisplayed
			if #@items > @items.maxDisplayedItems
				@items.startDisplayIndex or= 1

		@items.selection = 1

		while @items.selection <= #@items and not @\isSelectable @items[@items.selection]
			@items.selection += 1

		if @items.selection > #@items
			@items.selection = 1

		@\checkOverflows!

	getItemRectangle: (i, item) =>
		{
			x: @x
			y: @y + 60 * i
			w: 24 + @font\getWidth(item.label) + 2
			h: 45
		}

	print: (text, x, y, color) =>
		love.graphics.setColor 0, 0, 0, color[4]
		love.graphics.print text, x + 2, y + 0
		love.graphics.print text, x - 2, y + 0
		love.graphics.print text, x + 0, y + 2
		love.graphics.print text, x + 0, y - 2

		love.graphics.print text, x + 2, y + 2
		love.graphics.print text, x - 2, y - 2
		love.graphics.print text, x + 2, y - 2
		love.graphics.print text, x - 2, y + 2

		love.graphics.setColor color
		love.graphics.print text, x, y

	draw: =>
		if @items.draw
			return @items.draw self

		love.graphics.setFont @font

		alpha = if @selectionTime and @selectionTime >= 0.25
			255 * (1 - (@selectionTime - 0.25) / 0.25)
		elseif @drawTime <= 0.25
			255 * @drawTime * 4
		else
			255

		start = @items.startDisplayIndex or 1
		for i = start, start + (@items.maxDisplayedItems or math.huge) - 1
			item = @items[i]

			unless item
				break

			r = @\getItemRectangle i - start + 1, item

			love.graphics.setColor 127, 127, 127, alpha
			love.graphics.line r.x, r.y + r.h, r.x + r.w, r.y + r.h

			color = if i == @items.selection
				if @inputCatchMode
					c = 32 * math.sin @drawTime * 5
					{127 + 16 + c, 191 + 16 + c, 255}
				elseif @selectionTime and @selectedItem == item
					c = 64 * math.sin @selectionTime * 32
					{255, 191 + c, 191 + c, alpha}
				else
					c = 32 * math.sin @drawTime * 5
					{255, 127 + 16 + c, 63 + 16 + c, alpha}
			elseif @\isSelectable item
				{255, 255, 255, alpha}
			else
				{127, 127, 127, alpha}

			@\print item.label, r.x + 12, r.y - 20, color

			if item.rlabel
				@\print item.rlabel,
					r.x - 12 + 600 - @font\getWidth(item.rlabel),
					r.y - 20,
					color

	update: (dt) =>
		@drawTime += dt

		if @inputCatchMode
			return

		if @selectedItem
			if @selectionTime
				@selectionTime += dt

				if @selectionTime < 0.5
					return

			item = @selectedItem

			if type(item.onSelection) == "function"
				item.onSelection self, item
			else
				@\setItemsList item.onSelection

			@selectedItem = nil
			@selectionTime = nil

	keypressed: (key, ...) =>
		if @inputCatchMode
			@inputCatchMode = false

			@selectedItem.onInputCatch self, key, ...

			@selectedItem = nil

			return

		if @selectedItem
			return

		if key == "return" or key == "kpenter" or key == "kp6"
			item = @items[@items.selection]

			if item.onSelection
				if item.onImmediateSelection
					item.onImmediateSelection self
				@selectedItem = item
				@selectionTime = 0

				if item.noTransition
					@selectionTime = math.huge
			elseif item.onInputCatch
				@inputCatchMode = true
				@selectedItem = item
				print "Entering input-catch state. Sort-of."
		elseif key == "up" or key == "kp8"
			@items.selection = (@items.selection - 2) % #@items + 1

			while not @\isSelectable @items[@items.selection]
				@items.selection = (@items.selection - 2) % #@items + 1

			@\checkOverflows!
		elseif key == "down" or key == "kp2"
			@items.selection = (@items.selection) % #@items + 1

			while not @\isSelectable @items[@items.selection]
				@items.selection = (@items.selection) % #@items + 1

			@\checkOverflows!
		elseif key == "tab" or key == "escape" or key == "kp4"
			if @items.parent
				@selectionTime = 0
				@selectedItem = {
					onSelection: =>
						@\setItemsList @items.parent
				}
			else
				@items.selection = #@items

	checkOverflows: =>
		start = @items.startDisplayIndex or 1
		maxItems = @items.maxDisplayedItems or math.huge

		if start < @items.selection - maxItems + 1
			@items.startDisplayIndex = @items.selection - maxItems + 1
		elseif start > @items.selection
			@items.startDisplayIndex = @items.selection

