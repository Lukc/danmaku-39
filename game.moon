
{Manager: StateManager} = require "ui.state"

local stateManager

love.load = ->
	stateManager = StateManager!
	stateManager\bindEvents love

	stateManager\setState require "ui.menu"

