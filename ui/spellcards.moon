
{:Danmaku, :Boss} = require "danmaku"

Menu = require "ui.tools.menu"

data = require "data"

state = {}

updateSpellcardsList = ->
	newValues = {
		maxDisplayedItems: 15
	}

	difficulty = do
		string = state.optionsMenu.items[1].value
		Danmaku.Difficulties[string]

	for boss in *data.bosses
		insertedBossItem = false

		for spellcard in *boss
			unless spellcard.name
				continue

			difficultyMatches = false
			for i, d in ipairs spellcard.difficulties
				if d == difficulty
					difficultyMatches = true
					break

			unless difficultyMatches
				continue

			unless insertedBossItem
				insertedBossItem = true

				table.insert newValues, {
					label: boss.name
					height: 48
					onSelection: =>
						newState = require "ui.difficulty"
						newStage = {
							drawBossData: data.stages[1].drawBossData

							update: =>
								if @frame > 60 and #@enemies == 0
									@\endOfStage!

							[1]: =>
								@\addEntity Boss boss
						}

						state.manager\setState newState, newStage

				}

			table.insert newValues, {
				label: "    " .. spellcard.name
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

	state.spellcardsMenu\setItemsList newValues

state.enter = =>
	@descriptionsFont = love.graphics.newFont "data/fonts/miamanueva.otf", 18
	@optionsMenu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		{
			label: "Difficulty"
			type: "selector"
			values: do
				values = {}
				t = {v, k for k, v in pairs Danmaku.Difficulties}

				for i = 0, Danmaku.Difficulties["Ultra Extra"]
					s = t[i]

					if s
						table.insert values, s

				values
			value: "Normal"
			onValueChange: (item) =>
				updateSpellcardsList Danmaku.Difficulties[item.value]
		}
	}

	@spellcardsMenu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
	}

	updateSpellcardsList Danmaku.Difficulties.Normal

state.draw = =>
	x = (love.graphics.getWidth! - 1024)/2
	y = (love.graphics.getHeight! - 800)/2

	@optionsMenu.x = x + 10
	@optionsMenu.y = y + 15
	@optionsMenu.width = 1024 - 20

	@spellcardsMenu.x = x + 10
	@spellcardsMenu.y = y + 100

	@optionsMenu\draw!
	@spellcardsMenu\draw!

	hoveredSpellcard = do
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]

		unless menuItem
			return

		menuItem.spellcard

	unless hoveredSpellcard
		return

	-- FIXME: Attempt to draw stage metadata here?

	-- Drawing preview here
	love.graphics.setColor 255, 255, 255
	love.graphics.rectangle "line",
		x + 1024 - 20 - 480, y + 800 - 680 - 20,
		480, 600

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
	-- FIXME: Use the common input thing.
	if key == "left" or key == "right"
		return @optionsMenu\keypressed key, ...
	elseif key == "escape"
		state.manager\setState require("ui.menu"), true

	if #@spellcardsMenu.items > 0
		@spellcardsMenu\keypressed key, ...

state

