
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

	if noReset
		return

	data.load!

	menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		x: 200
		y: 200

		{
			label: "Adventure"
			onSelection: =>
				state.manager\setState require("ui.difficulty"), data.stages[1]
		}
		{
			label: "Extras"
		}
		{
			label: "Spellcards"
			onSelection: =>
				list = {
					maxDisplayedItems: 8
				}

				for stage in *data.stages
					table.insert list, {
						label: stage.title
						onSelection: =>
							state.manager\setState require("ui.spellcards"),
								stage
					}

				@\setItemsList list

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
	with c = math.min 255, @drawTime * 511
		love.graphics.setColor c, c, c

	menu\draw!

state.update = (dt) =>
	{:x, :y, :w, :h, :sizeModifier} = vscreen\update!

	menu.x = x + 200 * sizeModifier
	menu.y = y + 200 * sizeModifier

	menu.width = (w - 200 * 2) * sizeModifier
	menu.itemHeight = 65 * sizeModifier

	menu.font = fonts.get "miamanueva", 32 * sizeModifier

	menu\update dt

state

