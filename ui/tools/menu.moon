
data = require "data"

MenuItem = class
	getRectangle: (x = 0, y = 0) =>
		if @x or @y
			print @x, @y
		{
			x: @x or x
			y: @y or y
			w: @width or @menu.width
			h: @height or 65
		}

	init: (menu) =>
		@menu = menu

		if @type == "selector"
			unless @value
				@value = @values[1]

	hovered: =>
		itemsList = @menu.items

		itemsList[itemsList.selection] == self

	getDefaultAlpha: =>
		if @menu.selectionTime and @menu.selectionTime >= 0.25
			255 * (1 - (@menu.selectionTime - 0.25) / 0.25)
		elseif @menu.drawTime <= 0.25
			255 * @menu.drawTime * 4
		else
			255

	getDefaultColor: =>
		alpha = @\getDefaultAlpha!

		if @\hovered!
			if @menu.inputCatchMode
				c = 32 * math.sin @menu.drawTime * 5
				{127 + 16 + c, 191 + 16 + c, 255}
			elseif @menu.selectionTime and @menu.selectedItem == self
				c = 64 * math.sin @menu.selectionTime * 32
				{255, 191 + c, 191 + c, alpha}
			else
				c = 32 * math.sin @menu.drawTime * 5
				{255, 127 + 16 + c, 63 + 16 + c, alpha}
		elseif @menu\isSelectable self
			{255, 255, 255, alpha}
		else
			{127, 127, 127, alpha}

	draw: (x, y) =>
		unless @label
			return

		r = @\getRectangle x, y

		color = @\getDefaultColor!

		if @type == "check"
			love.graphics.rectangle "line",
				r.x + 7, r.y + 5,
				24, 24
			if @value
				@menu\print "x", r.x + 12, r.y - 20, color

			@menu\print @label, r.x + 47, r.y - 20, color
		else
			if @align == "center"
				@menu\print @label,
					r.x + (r.w - @menu.font\getWidth @label) / 2,
					r.y - 20, color
			else
				@menu\print @label, r.x + 12, r.y - 20, color

			if @type == "selector"
				label = tostring(@value)
				@menu\print label, r.x - 12 + 600 - @menu.font\getWidth(label),
					r.y - 20,
					color

		if @rlabel
			@menu\print @rlabel,
				r.x - 12 + 600 - @menu.font\getWidth(@rlabel),
				r.y - 20,
				color

	__tostring: => "<MenuItem: \"#{@label}\">"

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

		@width = arg.width or (1024 - 2 * @x)
		@height = arg.height or (800 - @y)

		@inputCatchMode = false

		for item in *arg
			table.insert @items, item

		@items.root = true

		@\setItemsList @items

	isSelectable: (item) =>
		return item.onSelection or item.onInputCatch or
			item.type == "check" or
			item.type == "selector"

	setItemsList: (target) =>
		unless target.parent or target == @items.parent or target.root
			print "setting parent"
			target.parent = @items

		for item in *target
			setmetatable item, MenuItem.__base

			item\init self

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

	print: (text, x, y, color, font = nil) =>
		if font
			love.graphics.setFont font

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

		if font
			love.graphics.setFont @font

	draw: =>
		love.graphics.setFont @font

		x, y = @x, @y

		start = @items.startDisplayIndex or 1
		for i = start, start + (@items.maxDisplayedItems or math.huge) - 1
			item = @items[i]

			unless item
				break

			r = item\getRectangle!

			item\draw x, y

			y += r.h

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

		if data.isMenuInput key, "select"
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
			elseif item.type == "check"
				item.value = not item.value
		elseif data.isMenuInput key, "up"
			@items.selection = (@items.selection - 2) % #@items + 1

			while not @\isSelectable @items[@items.selection]
				@items.selection = (@items.selection - 2) % #@items + 1

			@\checkOverflows!
		elseif data.isMenuInput key, "down"
			@items.selection = (@items.selection) % #@items + 1

			while not @\isSelectable @items[@items.selection]
				@items.selection = (@items.selection) % #@items + 1

			@\checkOverflows!
		elseif data.isMenuInput key, "right"
			item = @items[@items.selection]

			if item.type == "check"
				item.value = not item.value

				if item.onValueChange
					item.onValueChange self, item
			elseif item.type == "selector"
				currentIndex = 1
				for i = 1, #item.values
					if item.values[i] == item.value
						currentIndex = i

						break

				item.value = item.values[currentIndex % #item.values + 1]

				if item.onValueChange
					item.onValueChange self, item
		elseif data.isMenuInput key, "left"
			item = @items[@items.selection]

			if item.type == "check"
				item.value = not item.value

				if item.onValueChange
					item.onValueChange self, item
			elseif item.type == "selector"
				currentIndex = 1
				for i = 1, #item.values
					if item.values[i] == item.value
						currentIndex = i

						break

				item.value = item.values[(currentIndex - 2) % #item.values + 1]

				if item.onValueChange
					item.onValueChange self, item
		elseif data.isMenuInput key, "back"
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

	__tostring: =>
		"<Menu: #{#@items} items>"

