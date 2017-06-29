
{:Danmaku, :Boss} = require "danmaku"

Menu = require "ui.tools.menu"

data = require "data"
vscreen = require "vscreen"
fonts = require "fonts"

state = {}

updateSpellcardsList = ->
	newValues = {
		maxDisplayedItems: 15
		itemHeight: 48
	}

	state.playableSpellcard = false

	for boss in *(state.stage.bosses or {})
		insertedBossItem = false

		for spellcard in *boss
			unless spellcard.name
				continue

			unless insertedBossItem
				insertedBossItem = true

				table.insert newValues, {
					label: boss.name
					:boss
					onSelection: =>
						newState = require "ui.difficulty"
						newStage = {
							name: "Boss - " .. boss.name
							difficulties: boss.difficulties -- XXX check
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
				label: spellcard.name
				:spellcard
				draw: (x, y) =>
					r = @\getRectangle x, y
					defaultColor = @\getDefaultColor!

					sameDifficulty = false

					for stageDifficulty in *(state.stage.difficulties or {})
						for spellDifficulty in *(spellcard.difficulties or {})
							if stageDifficulty == spellDifficulty
								sameDifficulty = true
								break

					color = if sameDifficulty
						defaultColor
					else
						o = if @\hovered!
							math.sin @menu.drawTime * 5
						else
							0

						{255, 127 + 64 * o, 127 + 64 * o}

					@menu\print @label,
						r.x + 48 * vscreen.rectangle.sizeModifier,
						r.y - 20,
						color
				onSelection: =>
					newState = require "ui.difficulty"
					newStage = {
						name: "Spellcard - " .. spellcard.name
						difficulties: spellcard.difficulties
						drawBossData: data.stages[1].drawBossData

						update: =>
							if @frame > 60 and #@enemies == 0
								@\endOfStage!

						[1]: =>
							boss = {k,v for k,v in pairs boss}

							boss[1] = spellcard

							for i = 2, #boss
								boss[i] = nil

							for i = 1, #boss
								print i, boss[i]

							@\addEntity Boss boss
					}

					state.manager\setState newState, newStage
			}

			state.playableSpellcard = true

	unless state.playableSpellcard
		table.insert newValues, {
			label: "No playable spellcards."
		}

	state.spellcardsMenu\setItemsList newValues

	state.spellcardsMenu.items.selection = 0
	state.playStageMenu.items.selection = 1

state.enter = (stage) =>
	@stage = stage
	@playStageMenu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		{
			label: "Play stage!"
			onSelection: =>
				state.manager\setState require("ui.difficulty"), state.stage
		}
	}

	@spellcardsMenu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
	}

	updateSpellcardsList!

state.draw = =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen.rectangle
	screenWidth = love.graphics.getWidth!

	@playStageMenu\draw!
	@spellcardsMenu\draw!

	hoveredBoss = do
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]

		if menuItem
			menuItem.boss

	hoveredSpellcard = unless hoveredBoss
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]

		if menuItem
			menuItem.spellcard

	with oldPrint = love.graphics.print
		-- FIXME: Hacky as fuck. Children, don’t do this at home.
		love.graphics.print = (text, x, y) ->
			love.graphics.printf text, x, y, 480 * sizemod, "left"

		if hoveredBoss
			fontHeight = @descriptionsFont\getHeight!

			Y = h - fontHeight * 1.5

			_, wrap = @descriptionsFont\getWrap hoveredBoss.description or "???",
				380 * sizemod

			-- FIXME: Add portrait or something.

			for i = 1, #wrap
				@playStageMenu\print wrap[#wrap - i + 1],
					screenWidth - (20 + 400) * sizemod,
					Y,
					{200, 200, 200},
					@descriptionsFont
				Y -= fontHeight
		elseif hoveredSpellcard
			-- FIXME: Drawing preview here
			love.graphics.setColor 255, 255, 255
			love.graphics.rectangle "line",
				screenWidth - (20 + 480) * sizemod,
				y + (vscreen.height - 680 - 20) * sizemod,
				480 * sizemod, 600 * sizemod

			@spellcardsMenu\print "#{hoveredSpellcard.description or "???"}",
				screenWidth - (20 + 480) * sizemod,
				y + (vscreen.height - 80 - 20) * sizemod,
				{200, 200, 200},
				@descriptionsFont
		else
			-- FIXME: Add background or something.
			@playStageMenu\print "#{state.stage.description or "???"}",
				screenWidth - (20 + 400) * sizemod,
				y + 160 * sizemod,
				{200, 200, 200},
				@descriptionsFont

		love.graphics.print = oldPrint

state.update = (dt) =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen\update!
	screenWidth = love.graphics.getWidth!

	@descriptionsFont = fonts.get "Sniglet-Regular", 18 * sizemod

	@playStageMenu.x = 15 * sizemod
	@playStageMenu.y = y + 35 * sizemod
	@playStageMenu.width = screenWidth - 20 * sizemod
	@playStageMenu.font = fonts.get "Sniglet-Regular", 32 * sizemod

	@spellcardsMenu.x = 15 * sizemod
	@spellcardsMenu.y = y + 100 * sizemod
	@spellcardsMenu.width = screenWidth - (20 + 400) * sizemod
	@spellcardsMenu.font = fonts.get "Sniglet-Regular", 24 * sizemod
	@spellcardsMenu.itemHeight = 36 * sizemod

	@playStageMenu\update dt
	@spellcardsMenu\update dt

state.select = =>
	if @playStageMenu.items.selection == 1
		@playStageMenu\select!
	else
		@spellcardsMenu\select!

state.down = =>
	unless state.playableSpellcard
		return

	if @playStageMenu.items.selection == 1
		@playStageMenu.items.selection = 0
		@spellcardsMenu.items.selection = 1
	else
		items = @spellcardsMenu.items

		if items.selection == #items
			items.selection = 0
			@playStageMenu.items.selection = 1
		else
			@spellcardsMenu\down!

state.up = =>
	unless state.playableSpellcard
		return

	items = @spellcardsMenu.items

	if @playStageMenu.items.selection == 1
		@playStageMenu.items.selection = 0
		items.selection = #items
	else
		if items.selection == 1
			items.selection = 0
			@playStageMenu.items.selection = 1
		else
			@spellcardsMenu\up!

state.back = =>
	-- FIXME: Force a transition.
	state.manager\setState require("ui.menu"), true

state.keypressed = (key, ...) =>
	if data.isMenuInput(key, "select")
		return @\select!
	elseif data.isMenuInput(key, "down")
		return @\down!
	elseif data.isMenuInput(key, "up")
		return @\up!
	elseif data.isMenuInput key, "back"
		return @\back!

	if #@spellcardsMenu.items > 0
		@spellcardsMenu\keypressed key, ...

state.gamepadpressed = (joystick, button) =>
	config = data.config

	if button == config.menuGamepadInputs.select
		@\select!
	elseif button == config.menuGamepadInputs.down
		@\down!
	elseif button == config.menuGamepadInputs.up
		@\up!
	elseif button == config.menuGamepadInputs.back
		@\back!

state

