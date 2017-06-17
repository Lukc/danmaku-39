
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

		for item in *arg
			table.insert @items, item

	setItemsList: (target) =>
		unless target.parent or target == @items.parent
			target.parent = @items

		@items = target
		@drawTime = 0

		-- FIXME: It should actually be the first valid item, but…
		@items.selection = 1

		while @items.selection <= #@items and not @items[@items.selection].onSelection
			@items.selection += 1

		if @items.selection > #@items
			@items.selection = 1

	getItemRectangle: (i, item) =>
		{
			x: @x
			y: @y + 60 * i
			w: 24 + @font\getWidth(item.label) + 2
			h: 45
		}

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

		for i = 1, #@items
			item = @items[i]

			r = @\getItemRectangle i, item

			love.graphics.setColor 127, 127, 127, alpha
			love.graphics.line r.x, r.y + r.h, r.x + r.w, r.y + r.h

			love.graphics.setColor 0, 0, 0, alpha
			love.graphics.print item.label, r.x + 14, r.y - 20 + 0
			love.graphics.print item.label, r.x + 10, r.y - 20 + 0
			love.graphics.print item.label, r.x + 12, r.y - 20 + 2
			love.graphics.print item.label, r.x + 12, r.y - 20 - 2

			love.graphics.print item.label, r.x + 14, r.y - 20 + 2
			love.graphics.print item.label, r.x + 10, r.y - 20 - 2
			love.graphics.print item.label, r.x + 14, r.y - 20 - 2
			love.graphics.print item.label, r.x + 10, r.y - 20 + 2

			if i == @items.selection
				if @selectionTime and @selectedItem == item
					c = 63 * math.sin @selectionTime * 32
					love.graphics.setColor 255, 195 + c, 195 + c, alpha
				else
					c = 32 * math.sin @drawTime * 5
					love.graphics.setColor 255, 127 + 16 + c, 63 + 16 + c, alpha
			elseif item.onSelection
				love.graphics.setColor 255, 255, 255, alpha
			else
				love.graphics.setColor 127, 127, 127, alpha

			love.graphics.print item.label, r.x + 12, r.y - 20

	drawCharactersList: =>
		alpha = if @selectionTime and @selectionTime >= 0.25
			255 * (1 - (@selectionTime - 0.25) / 0.25)
		elseif @drawTime <= 0.25
			255 * @drawTime * 4
		else
			255

		for i = 1, #@items
			item = @items[i]
			{:player} = item

			if i == @items.selection
				love.graphics.setColor 255, 255, 255, alpha

				if player
					love.graphics.print player.name,
						@x + 12, @y - 20
					love.graphics.print player.title,
						@x + 42, @y + 30
					love.graphics.print player.mainAttackName,
						@x + 12, @y + 100
					love.graphics.print player.secondaryAttackName,
						@x + 12, @y + 150
				else
					love.graphics.print item.label,
						@x + 12, @y - 20

	update: (dt) =>
		@drawTime += dt

		if @selectedItem
			@selectionTime += dt

			if @selectionTime < 0.5
				return

			item = @selectedItem
			@selectedItem = nil
			@selectionTime = nil

			if type(item.onSelection) == "function"
				item.onSelection self, item
			else
				@\setItemsList item.onSelection

	keypressed: (key, ...) =>
		if @selectedItem
			return

		if key == "return"
			item = @items[@items.selection]

			if item.onSelection
				if item.onImmediateSelection
					item.onImmediateSelection self
				@selectedItem = item
				@selectionTime = 0
		elseif key == "up"
			@items.selection = (@items.selection - 2) % #@items + 1

			while not @items[@items.selection].onSelection
				@items.selection = (@items.selection - 2) % #@items + 1
		elseif key == "down"
			@items.selection = (@items.selection) % #@items + 1

			while not @items[@items.selection].onSelection
				@items.selection = (@items.selection) % #@items + 1
		elseif key == "tab" or key == "escape"
			if @items.parent
				@selectionTime = 0
				@selectedItem = {
					onSelection: =>
						@\setItemsList @items.parent
				}
			else
				@items.selection = #@items

