
state = {}

-- TODO
--	- Resolution management.
--	- .enter and .leave transitions.
--	- menu.selection change transitions.
--	- Obviously, we need textures for the background and menu items.

local menu

state.enter = =>
	while menu.parent
		menu = menu.parent

	menu.selection = 1
	menu.drawTime = 0

	@drawTime  = 0

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
					-- FIXME: Do a proper transition, please.
					menu = menu.parent
			}
		}
	}
	{
		label: "Quit"
		onSelection: =>
			love.event.quit!
	}
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

	love.graphics.print "Press “Enter” to select…", 200, 200

	alpha = if menu.selectionTime and menu.selectionTime >= 0.25
		255 * (1 - (menu.selectionTime - 0.25) / 0.25)
	elseif menu.drawTime <= 0.25
		255 * menu.drawTime * 4
	else
		255

	for i = 1, #menu
		item = menu[i]

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

		love.graphics.rectangle "line", 200,      200 + 50 * i, 200, 40
		love.graphics.print item.label, 200 + 12, 200 + 50 * i + 12

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
			item.onSelection.parent = menu
			menu = item.onSelection
			menu.drawTime = 0

			-- FIXME: It should actually be the first valid item, but…
			menu.selection = 1

state

