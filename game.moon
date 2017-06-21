
{Manager: StateManager} = require "ui.state"

data = require "data"

local stateManager

love.load = ->
	stateManager = StateManager!
	stateManager\bindEvents love

	stateManager\setState require "ui.splash"

