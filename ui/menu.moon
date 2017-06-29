
{:Stage, :Boss} = require "danmaku"

state = {}

vscreen = require "vscreen"
data = require "data"
fonts = require "fonts"

-- TODO: We need textures for the background, and possibly for the menu items.

Menu = require "ui.tools.menu"

playerInputsMenu = (id) ->
	{
		label: "Player #{id} controls"
		onSelection: =>
			list = {}

			for input in *{"up", "down", "left", "right", "firing", "bombing", "focusing"}
				table.insert list, {
					label: input
					rlabel: data.config.inputs[id][input]
					onInputCatch: (key, scanCode) =>
						for _, item in ipairs self.items
							if item.label == input
								item.rlabel = scanCode

						data.config.inputs[id][input] = scanCode
						data.saveConfig!
				}

			@\setItemsList list
	}

local menu

state.enter = (noReset) =>
	@drawTime  = 0
	@transitionTime = nil

	if noReset
		return

	data.load!

	-- For development purposes.
	love.graphics.setBackgroundColor {31, 31, 31}

	menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		x: 200
		y: 200

		{
			label: "Adventure"
			onImmediateSelection: =>
				state.transitionTime = 0
			onSelection: =>
				state.manager\setState require("ui.difficulty"), data.stages[1]
		}
		{
			label: "Extras"
		}
		{
			label: "Stories & Spells"
			onSelection: =>
				state.manager\setState require("ui.spellcards")

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
				playerInputsMenu 1
				playerInputsMenu 2
				playerInputsMenu 3
				playerInputsMenu 4
				{
					label: "Mods"
					onSelection: =>
						list = {
							maxDisplayedItems: 8
						}

						onSelection = =>
							modName = @selectedItem.label
							blockedMods = data.config.blockedMods

							@selectedItem.rlabel = switch @selectedItem.rlabel
								when "v"
									blockedMods[modName] = true
									"x"
								when "x"
									blockedMods[modName] = nil
									"v"

							data.saveConfig!
							data.load!

						for mod in *data.mods
							table.insert list, {
								label: "#{mod.name or mod}"
								rlabel: data.config.blockedMods[mod.name] and
									"x" or "v"
								noTransition: true
								:onSelection
							}

						@\setItemsList list
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

state.keypressed = (...) =>
	menu\keypressed ...

state.gamepadpressed = (...) =>
	menu\gamepadpressed ...

state.draw = =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen.rectangle

	alpha = menu.items[1]\getDefaultAlpha!
	alpha = if @drawTime <= 0.25
		255 * @drawTime / 0.25
	elseif @transitionTime
		255 * (0.5 - @transitionTime) / 0.25
	else
		255 -- Default formula will come here.

	alpha = math.min 255, alpha

	menu\print "Story",
		x + 200 * sizemod, y + 4 * sizemod,
		{255, 255, 255, alpha},
		fonts.get "miamanueva", 72 * sizemod

	menu\print "of the",
		x + 400 * sizemod, y + (72 + 28 - 8) * sizemod,
		{191, 223, 255, alpha},
		fonts.get "miamanueva", 54 * sizemod

	menu\print "New Wonderland",
		x + 100 * sizemod, y + (72 + 54 + 28) * sizemod,
		{255, 255, 255, alpha},
		fonts.get "miamanueva", 72 * sizemod

	menu\draw!

state.update = (dt) =>
	@drawTime += dt

	if @transitionTime
		@transitionTime += dt

	{:x, :y, :w, :h, :sizeModifier} = vscreen\update!

	menu.x = x + 100 * sizeModifier
	menu.y = y + 375 * sizeModifier

	menu.width = w - (100 * 2) * sizeModifier
	menu.itemHeight = 48 * sizeModifier

	menu.font = fonts.get "Sniglet-Regular", 32 * sizeModifier

	if menu.items.root
		menu.items[1].x = x + 140 * sizeModifier
		menu.items[3].x = x + 120 * sizeModifier
		menu.items[4].x = x + 160 * sizeModifier
		menu.items[5].x = x + 130 * sizeModifier
		menu.items[6].x = x + 120 * sizeModifier
		menu.items[7].x = x + 140 * sizeModifier

	menu\update dt

state

