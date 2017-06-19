
state = {}

Menu = require "ui.tools.menu"

state.enter = (stage, players) =>
	@stage = stage
	@players = players

	@menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32

		x: 200
		y: 200

		{
			label: "CAUTION: This menu does nothing."
		}
		{
			label: "CAUTION: It’s still a mostly unimplemented WIP."
		}
		{
			type: "selector"
			values: {"Normal", "Hard", "Lunatic"}
			label: "Normal"
			noTransition: true
		}
		{
			type: "check"
			label: "training"
			onSelection: =>
				print @selectedItem.value
			noTransition: true
		}
		{
			type: "check"
			label: "pacific"
			onSelection: =>
			noTransition: true
		}
		{
			label: "Play!"
			onSelection: =>
				state.manager\setState require("ui.game"), @stage, @players
		}
	}

state.keypressed = (key, scanCode, ...) =>
	if key == "escape" or key == "tab"
		return @manager\setState require("ui.characters"), nil, true

	@menu\keypressed key, scanCode, ...

state.update = (dt) =>
	@menu\update dt

state.draw = =>
	@menu\draw!

state

