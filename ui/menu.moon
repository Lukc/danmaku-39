
state = {}

-- TODO: We need textures for the background, and possibly for the menu items.

class Menu
	new: (arg) =>
		arg or= {}

		@font = arg.font
		@items = {
			selection: 1
		}
		@drawTime = 0

		for item in *arg
			table.insert @items, item

	setItemsList: (target) =>
		target.parent = @items
		@items = target
		@drawTime = 0

		-- FIXME: It should actually be the first valid item, but…
		@items.selection = 1

	getItemRectangle: (i, item) =>
		{
			x: @x
			y: @y + 60 * i
			w: 24 + @font\getWidth(item.label) + 2
			h: 45
		}

	draw: =>
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
				if @selectionTime
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

	update: (dt) =>
		@drawTime += dt
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
			@items.selection = #@items

menu = Menu {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
	x: 200
	y: 200

	{
		label: "Adventure"
		onSelection: =>
			charactersList = [{
				label: "Character #{i}"
				onSelection: =>
					state.manager\setState require "ui.game"
			} for i = 1, 3]

			table.insert charactersList, {
				label: "Go back"
				onSelection: => @\setItemsList @items.parent
			}

			@\setItemsList charactersList
	}
	{
		label: "Extras"
	}
	{
		label: "Multiplayer"
	}
	{
		label: "Training"
	}
	{
		label: "Highscores"
	}
	{
		label: "Replays"
	}
	{
		label: "Options"
		onSelection: {
			{
				label: "Player 1 controls"
			}
			{
				label: "Player 2 controls"
			}
			{
				label: "Player 3 controls"
			}
			{
				label: "Player 4 controls"
			}
			{
				label: "Go back"
				onSelection: =>
					@\setItemsList @items.parent
			}
		}
	}
	{
		label: "Quit"
		onSelection: =>
			love.event.quit!
	}
}

state.enter = =>
	while menu.parent
		menu = menu.parent

	menu.selection = 1
	menu.drawTime = 0

	@drawTime  = 0

	menuFont = love.graphics.newFont "data/fonts/miamanueva.otf", 32

state.keypressed = (...) =>
	menu\keypressed ...

state.draw = =>
	with c = math.min 255, @drawTime * 511
		love.graphics.setColor c, c, c

	love.graphics.print "Press “Enter” to select…", 200, 160

	menu\draw!

state.update = (dt) =>
	w, h = love.graphics.getWidth!, love.graphics.getHeight!

	x = (w - 1024) / 2
	y = (h - 800) / 2

	menu.x = x + 200
	menu.y = y + 200

	menu\update dt

state

