
{:Danmaku, :Boss} = require "danmaku"

Menu = require "ui.tools.menu"

data = require "data"
vscreen = require "vscreen"
fonts = require "fonts"

state = {}

portraits = {
	Coactlicue: love.graphics.newImage "data/art/Coactlicue.png"
}

bossMenuItem = (boss) -> {
	label: boss.name
	:boss
	draw: (x, y) =>
		r = @\getRectangle x, y
		defaultColor = @\getDefaultColor!
		sizemod = vscreen.rectangle.sizeModifier

		color = do
			o = if @\hovered!
				math.sin @menu.drawTime * 5
			else
				0

			{127 + 64 * o, 127 + 64 * o, 191 + 64 * o, @\getDefaultAlpha!}

		@menu\print @label,
			r.x + 12 * vscreen.rectangle.sizeModifier,
			r.y - 2,
			color,
			fonts.get "Sniglet-Regular", 36 * sizemod

		for i = 1, 3
			color[i] *= 0.75

		@menu\print boss.title or "---",
			r.x + 12 * vscreen.rectangle.sizeModifier,
			r.y - 2 + 30 * sizemod,
			color,
			fonts.get "Sniglet-Regular", 22 * sizemod
	onSelection: =>
		newState = require "ui.difficulty"
		newStage = {
			name: "Boss - " .. boss.name
			difficulties: boss.difficulties
			drawBossData: data.stages[1].drawBossData
			screenRatio: stage.screenRatio

			update: =>
				if @frame > 60 and #@enemies == 0
					@\endOfStage!

			[1]: =>
				@\addEntity Boss boss
		}

		state.manager\setState newState, newStage

}

spellcardMenuItem = (stage, boss, spellcard) -> {
	label: spellcard.name
	:spellcard
	draw: (x, y) =>
		r = @\getRectangle x, y
		defaultColor = @\getDefaultColor!
		sizemod = vscreen.rectangle.sizeModifier

		sameDifficulty = false

		for stageDifficulty in *(stage.difficulties or {})
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

			{255, 127 + 64 * o, 127 + 64 * o, @\getDefaultAlpha!}

		@menu\print @label,
			r.x + 24 * vscreen.rectangle.sizeModifier,
			r.y - 2,
			color

		for i = 1, 3
			color[i] *= 0.75

		@menu\print "#{spellcard.sign or "Unknown"} sign",
			r.x + 48 * sizemod,
			r.y - 2 + 30 * sizemod,
			color,
			fonts.get "Sniglet-Regular", 22 * sizemod
	onSelection: =>
		newState = require "ui.difficulty"
		newStage = {
			name: "Spellcard - " .. spellcard.name
			difficulties: spellcard.difficulties
			drawBossData: data.stages[1].drawBossData
			screenRatio: stage.screenRatio

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

updateSpellcardsList = ->
	newValues = {
		maxDisplayedItems: 10
		itemHeight: 48
		root: true
	}

	state.playableSpellcard = false

	for story in *data.stories
		table.insert newValues, {
			label: story.name
			onSelection: =>
				print "Play the whole story, maybe?"
		}

		for stage in *story.stages or {}
			stageMenuItems = {}

			for boss in *(stage.bosses or {})
				insertedBossItem = false

				for spellcard in *boss
					unless spellcard.name
						continue

					unless insertedBossItem
						insertedBossItem = true

						table.insert stageMenuItems, bossMenuItem boss

					table.insert stageMenuItems, spellcardMenuItem stage, boss, spellcard

					state.playableSpellcard = true

			unless state.playableSpellcard
				table.insert stageMenuItems, {
					label: "No playable spellcards."
				}

			table.insert newValues, {
				label: "    " .. (stage.title or "???")
				onSelection: =>
					state.stage = stage
					state.playStageMenu.drawTime = 0

					if #stageMenuItems == 0
						state.playStageMenu.items.selection = 1
						state.spellcardsMenu.items.selection = 0

					@\setItemsList stageMenuItems
			}

	state.spellcardsMenu\setItemsList newValues

	state.spellcardsMenu.items.selection = 1
	state.playStageMenu.items.selection = 0

state.enter = (stage) =>
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

		onSelectionChange: =>
			state.hoverTime = 0
	}

	@hoverTime = 0

	updateSpellcardsList!

drawDifficulties = (thing) =>
	{:y, sizeModifier: sizemod} = vscreen.rectangle
	screenWidth = love.graphics.getWidth!

	difficulties = thing.difficulties or {}

	Y = y + (vscreen.height - 120) * sizemod -
		#difficulties * @descriptionsFont\getHeight!

	for difficulty in *difficulties
		str = Danmaku.getDifficultyString difficulty

		@spellcardsMenu\print str,
			screenWidth - 40 * sizemod - @descriptionsFont\getWidth(str),
			Y,
			{200, 200, 200},
			@descriptionsFont

		Y += @descriptionsFont\getHeight!

state.draw = =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen.rectangle
	screenWidth = love.graphics.getWidth!
	screenHeight = love.graphics.getHeight!

	if state.stage
		@playStageMenu\draw!

	@spellcardsMenu\draw!

	hoveredStage = do
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]

		if menuItem
			menuItem.stage

	hoveredBoss = unless hoveredStage
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]

		if menuItem
			menuItem.boss

	hoveredSpellcard = unless hoveredBoss or hoveredStage
		menuItem = @spellcardsMenu.items[@spellcardsMenu.items.selection]

		if menuItem
			menuItem.spellcard

	with oldPrint = love.graphics.print
		-- FIXME: Hacky as fuck. Children, don’t do this at home.
		love.graphics.print = (text, x, y) ->
			love.graphics.printf text, x, y, 480 * sizemod, "left"

		-- Illustrations and preview area. ~placeholder
		love.graphics.setColor 255, 255, 255
		love.graphics.rectangle "line",
			screenWidth - (20 + 480) * sizemod,
			y + (vscreen.height - 680 - 20) * sizemod,
			480 * sizemod, 600 * sizemod

		if hoveredBoss
			fontHeight = @descriptionsFont\getHeight!

			portrait = portraits[hoveredBoss.name]

			if portrait
				sizeRatio = 640 * sizemod / portrait\getHeight!
				sizeRatio = math.min sizeRatio, 480 * sizemod / portrait\getWidth!

				offset = math.max(0, 0.25 - state.hoverTime) / 0.25
				print offset

				with c = 255 - 255 * offset
					love.graphics.setColor c, c, c, c

				love.graphics.draw portrait,
					screenWidth - (20 + 480) * sizemod +
						(480 * sizemod - portrait\getWidth! * sizeRatio) / 2 -
						50 * offset * sizemod,
					y + (vscreen.height - 680 - 20) * sizemod,
					nil,
					sizeRatio, sizeRatio

			_, wrap = @descriptionsFont\getWrap hoveredBoss.description or "???",
				440 * sizemod

			Y = y + (vscreen.height - 600) * sizemod - fontHeight * (4.75 - #wrap)

			for i = 1, #wrap
				@playStageMenu\print wrap[#wrap - i + 1],
					screenWidth - (20 + 460) * sizemod,
					Y,
					{200, 200, 200},
					@descriptionsFont

				Y -= fontHeight

			drawDifficulties self, hoveredBoss
		elseif hoveredSpellcard
			-- FIXME: Drawing preview here

			@spellcardsMenu\print "#{hoveredSpellcard.description or "???"}",
				screenWidth - (20 + 480) * sizemod,
				y + (vscreen.height - 80 - 20) * sizemod,
				{200, 200, 200},
				@descriptionsFont

			drawDifficulties self, hoveredSpellcard
		elseif hoveredStage
			-- FIXME: Add background or something.
			@playStageMenu\print "#{hoveredStage.description or "???"}",
				screenWidth - (20 + 400) * sizemod,
				y + 160 * sizemod,
				{200, 200, 200},
				@descriptionsFont

		love.graphics.print = oldPrint

state.update = (dt) =>
	{:x, :y, :w, :h, sizeModifier: sizemod} = vscreen\update!
	screenWidth = love.graphics.getWidth!

	@hoverTime += dt

	@descriptionsFont = fonts.get "Sniglet-Regular", 18 * sizemod

	@playStageMenu.x = 15 * sizemod
	@playStageMenu.y = y + 35 * sizemod
	@playStageMenu.width = screenWidth - 20 * sizemod
	@playStageMenu.font = fonts.get "Sniglet-Regular", 32 * sizemod

	@spellcardsMenu.x = 15 * sizemod
	@spellcardsMenu.y = y + 100 * sizemod
	@spellcardsMenu.width = screenWidth - (20 + 400) * sizemod
	@spellcardsMenu.font = fonts.get "Sniglet-Regular", 24 * sizemod
	@spellcardsMenu.itemHeight = 64 * sizemod

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
		if #@spellcardsMenu.items != 0
			@playStageMenu.items.selection = 0
			@spellcardsMenu.items.selection = 1
	else
		items = @spellcardsMenu.items

		if items.selection == #items and state.stage
			items.selection = 0
			@playStageMenu.items.selection = 1
		else
			@spellcardsMenu\down!

state.up = =>
	unless state.playableSpellcard
		return

	items = @spellcardsMenu.items

	if @playStageMenu.items.selection == 1
		if #@spellcardsMenu.items != 0
			@playStageMenu.items.selection = 0
			items.selection = #items
	else
		if items.selection == 1 and state.stage
			items.selection = 0
			@playStageMenu.items.selection = 1
		else
			@spellcardsMenu\up!

state.back = =>
	-- FIXME: Force a transition.
	if @spellcardsMenu.items.root
		@spellcardsMenu.selectionTime = 0.25
		@spellcardsMenu.selectedItem = {
			onSelection: =>
				state.manager\setState require("ui.menu"), true
		}

		-- Forcing an empty selection to get a transition.
		@playStageMenu.selectionTime = 0.25
		@playStageMenu.selectedItem = {
			onSelection: =>
		}
	else
		@playStageMenu.selectionTime = 0
		@playStageMenu.selectedItem = {
			onSelection: =>
				@items.selection = 0
				state.stage = nil
		}

		@spellcardsMenu\back!

state.keypressed = (key, ...) =>
	if data.isMenuInput(key, "select")
		return @\select!
	elseif data.isMenuInput(key, "down")
		return @\down!
	elseif data.isMenuInput(key, "up")
		return @\up!
	elseif data.isMenuInput key, "back"
		return @\back!

	if @spellcardsMenu.items.selection > 0
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

