
state = {}

-- TODO
--	- Resolution management.
--	- .enter and .leave transitions.
--	- menu.selection change transitions.
--	- Obviously, we need textures for the background and menu items.

local menu, menuFont

switchToMenu = (target) ->
	target.parent = menu
	menu = target
	menu.drawTime = 0

	-- FIXME: It should actually be the first valid item, but…
	menu.selection = 1

state.enter = =>
	while menu.parent
		menu = menu.parent

	menu.selection = 1
	menu.drawTime = 0

	@drawTime  = 0

	menuFont = love.graphics.newFont "data/fonts/miamanueva.otf", 32

menu = {
	{
		label: "Adventure"
		onSelection: (state) =>
			state.manager\setState require "ui.game"
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
					switchToMenu menu.parent
			}
		}
	}
	{
		label: "Quit"
		onSelection: =>
			love.event.quit!
	}
}

getItemRectangle = (i, item) ->
	{
		x: 200
		y: 200 + 60 * i
		w: 24 + menuFont\getWidth(item.label) + 2
		h: 45
	}

state.keypressed = (key, ...) =>
	if menu.selectedItem
		return

	if key == "return"
		item = menu[menu.selection]

		if item.onSelection
			menu.selectedItem = item
			menu.selectionTime = 0
	elseif key == "up"
		menu.selection = (menu.selection - 2) % #menu + 1

		while not menu[menu.selection].onSelection
			menu.selection = (menu.selection - 2) % #menu + 1
	elseif key == "down"
		menu.selection = (menu.selection) % #menu + 1

		while not menu[menu.selection].onSelection
			menu.selection = (menu.selection) % #menu + 1
	elseif key == "tab" or key == "escape"
		menu.selection = #menu

state.draw = =>
	with c = math.min 255, @drawTime * 511
		love.graphics.setColor c, c, c

	love.graphics.print "Press “Enter” to select…", 200, 160

	alpha = if menu.selectionTime and menu.selectionTime >= 0.25
		255 * (1 - (menu.selectionTime - 0.25) / 0.25)
	elseif menu.drawTime <= 0.25
		255 * menu.drawTime * 4
	else
		255

	love.graphics.setFont menuFont

	for i = 1, #menu
		item = menu[i]

		r = getItemRectangle i, item

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

		if i == menu.selection
			if menu.selectionTime
				c = 63 * math.sin menu.selectionTime * 32
				love.graphics.setColor 255, 195 + c, 195 + c, alpha
			else
				c = 32 * math.sin @drawTime * 6
				love.graphics.setColor 255, 127 + 16 + c, 63 + 16 + c, alpha
		elseif item.onSelection
			love.graphics.setColor 255, 255, 255, alpha
		else
			love.graphics.setColor 127, 127, 127, alpha

		love.graphics.print item.label, r.x + 12, r.y - 20

state.update = (dt) =>
	@drawTime += dt
	menu.drawTime += dt

	if menu.selectedItem
		menu.selectionTime += dt

		if menu.selectionTime < 0.5
			return

		item = menu.selectedItem
		menu.selectedItem = nil
		menu.selectionTime = nil

		if type(item.onSelection) == "function"
			item.onSelection item, self
		else
			switchToMenu item.onSelection

state

