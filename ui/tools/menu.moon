
data = require "data"

MenuItem = class
	getRectangle: (x = 0, y = 0) =>
		if @x or @y
			print @x, @y
		{
			x: @x or x
			y: @y or y
			w: @width or @menu.width
			h: @height or @menu.itemHeight or 65
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
				@menu\print label, r.x - 12 + @menu.width - @menu.font\getWidth(label),
					r.y - 20,
					color

		if @rlabel
			@menu\print @rlabel,
				r.x - 12 + @menu.width - @menu.font\getWidth(@rlabel),
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

		@items.maxDisplayedItems = arg.maxDisplayedItems

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

	catchInput: (key, ...) =>
		if @inputCatchMode
			@inputCatchMode = false

			@selectedItem.onInputCatch self, key, ...

			@selectedItem = nil

			return true

		if @selectedItem
			return true

	select: =>
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

	up: =>
		@items.selection = (@items.selection - 2) % #@items + 1

		while not @\isSelectable @items[@items.selection]
			@items.selection = (@items.selection - 2) % #@items + 1

		@\checkOverflows!

	down: =>
		@items.selection = (@items.selection) % #@items + 1

		while not @\isSelectable @items[@items.selection]
			@items.selection = (@items.selection) % #@items + 1

		@\checkOverflows!

	right: =>
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

	left: =>
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

	back: =>
		if @items.parent
			@selectionTime = 0
			@selectedItem = {
				onSelection: =>
					@\setItemsList @items.parent
			}
		else
			@items.selection = #@items

	gamepadpressed: (joystick, button) =>
		config = data.config

		if @\catchInput button
			return

		if button == config.menuGamepadInputs.select
			@\select!
		elseif button == config.menuGamepadInputs.down
			@\down!
		elseif button == config.menuGamepadInputs.up
			@\up!
		elseif button == config.menuGamepadInputs.right
			@\right!
		elseif button == config.menuGamepadInputs.left
			@\left!
		elseif button == config.menuGamepadInputs.back
			@\back!

	keypressed: (key, ...) =>
		if @\catchInput key, ...
			return

		if data.isMenuInput key, "select"
			@\select!
		elseif data.isMenuInput key, "up"
			@\up!
		elseif data.isMenuInput key, "down"
			@\down!
		elseif data.isMenuInput key, "right"
			@\right!
		elseif data.isMenuInput key, "left"
			@\left!
		elseif data.isMenuInput key, "back"
			@\back!

	checkOverflows: =>
		start = @items.startDisplayIndex or 1
		maxItems = @items.maxDisplayedItems or math.huge

		if start < @items.selection - maxItems + 1
			@items.startDisplayIndex = @items.selection - maxItems + 1
		elseif start > @items.selection
			@items.startDisplayIndex = @items.selection

	__tostring: =>
		"<Menu: #{#@items} items>"

