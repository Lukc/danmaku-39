
{Manager: StateManager} = require "ui.state"

highscores = require "highscores"

local stateManager

love.load = ->
	highscores.load!

	stateManager = StateManager!
	stateManager\bindEvents love

	stateManager\setState require "ui.splash"

