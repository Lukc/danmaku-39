
{:Boss} = require "danmaku"

Menu = require "ui.tools.menu"

data = require "data"

state = {}

state.enter = =>
	@descriptionsFont = love.graphics.newFont "data/fonts/miamanueva.otf", 18
	@optionsMenu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		{
			label: "Options will go here"
		}
	}

	spellcardsList = {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
		maxDisplayedItems: 15
	}

	for boss in *data.bosses
		table.insert spellcardsList, {
			label: boss.name
			height: 48
		}

		for spellcard in *boss
			unless spellcard.name
				continue

			table.insert spellcardsList, {
				label: spellcard.name
				height: 48
				:spellcard
				onSelection: =>
					newState = require "ui.difficulty"
					newStage = {
						drawBossData: data.stages[1].drawBossData

						update: =>
							if @frame > 60 and #@enemies == 0
								@\endOfStage!

						[1]: =>
							boss = {k,v for k,v in pairs boss}

							@\addEntity Boss with boss
								[1] = spellcard
								[2] = nil
					}

					state.manager\setState newState, newStage
			}

	@spellcardsMenu = Menu spellcardsList

state.draw = =>
	x = (love.graphics.getWidth! - 1024)/2
	y = (love.graphics.getHeight! - 800)/2

	@optionsMenu.x = x + 10
	@optionsMenu.y = y + 15

	@spellcardsMenu.x = x + 10
	@spellcardsMenu.y = y + 100

	@optionsMenu\draw!
	@spellcardsMenu\draw!

	-- Drawing preview here
	love.graphics.setColor 255, 255, 255
	love.graphics.rectangle "line",
		x + 1024 - 20 - 480, y + 800 - 680 - 20,
		480, 600

	hoveredSpellcard = do
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]
		menuItem.spellcard

	-- FIXME: Hacky as fuck. Children, don’t do this at home.
	with print = love.graphics.print
		love.graphics.print = (text, x, y) ->
			love.graphics.printf text, x, y, 480, "left"

		@spellcardsMenu\print "#{hoveredSpellcard.description or ""}",
			x + 1024 - 20 - 480, y + 800 - 80 - 20, {200, 200, 200},
			@descriptionsFont

		love.graphics.print = print

state.update = (dt) =>
	@optionsMenu\update dt
	@spellcardsMenu\update dt

state.keypressed = (key, ...) =>
	if key == "escape"
		state.manager\setState require("ui.menu"), true

	@spellcardsMenu\keypressed key, ...

state

