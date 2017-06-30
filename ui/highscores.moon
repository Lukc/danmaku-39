
Danmaku = require "danmaku.danmaku"

Menu = require "ui.tools.menu"

data = require "data"
fonts = require "fonts"
vscreen = require "vscreen"
highscores = require "highscores"

state = {}

state.updateScoresList = =>
	scores = highscores.get10 {}, {
		{
			name: @characterName
			secondaryAttackName: @characterVariantName
		}
	}, {
		training: @training
		pacific:  @pacific
		noBombs:  @pacific
		difficulty: @difficulty
	}

	items = {}

	for score in *scores
		print score.stage, score.characters[1].name
		table.insert items, {
			label: "#{score.stage}"
			rlabel: "#{score.score}"
		}

	for i = #items, 9
		table.insert items, {
			label:  "---"
			rlabel: "---"
		}

	@scoresList\setItemsList items

	-- Used for display only. We therefore don’t need no hovered item.
	@scoresList.items.selection = 0

state.enter = =>
	@characterName = data.characters[1].name
	@characterVariantName = data.characterVariants[1].name
	@training = false
	@pacific = false
	@difficulty = 2

	@menu = Menu {
		font: fonts.get "Sniglet-Regular", 32
		{
			label: "Character"
			type: "selector"
			values: [c.name for c in *data.characters]
			value: @characterName
			onValueChange: (item) =>
				state.characterName = item.value
				state\updateScoresList!
		}
		{
			label: "Weapon"
			type: "selector"
			values: [v.name for v in *data.characterVariants]
			value: @characterVariantName
			onValueChange: (item) =>
				state.characterVariantName = item.value
				state\updateScoresList!
		}
		{
			label: "Difficulty"
			type: "selector"
			values: [v for k, v in ipairs Danmaku.DifficultyStrings]
			value: Danmaku.getDifficultyString @difficulty
			onValueChange: (item) =>
				state.difficulty = Danmaku.Difficulties[item.value]
				state\updateScoresList!
		}
		{
			label: "Training"
			type: "check"
			value: @training
			onValueChange: (item) =>
				state.training = item.value
				state\updateScoresList!
		}
		{
			label: "Pacific"
			type: "check"
			value: @pacific
			onValueChange: (item) =>
				state.pacific = item.value
				state.noBombs = item.value
				state\updateScoresList!
		}
	}

	@scoresList = Menu {
		font: fonts.get "Sniglet-Regular", 24
	}

	@\updateScoresList!

state.draw = =>
	@menu\draw!

	@scoresList\draw!

state.update = (dt) =>
	{:x, :y, :w, :h, :sizeModifier} = vscreen\update!

	@menu.font = fonts.get "Sniglet-Regular", 32 * sizeModifier
	@menu.x = x + 25 * sizeModifier
	@menu.y = y + 25 * sizeModifier
	@menu.width = w - 50 * sizeModifier
	@menu.itemHeight = 48 * sizeModifier

	@scoresList.font = fonts.get "Sniglet-Regular", 24 * sizeModifier
	@scoresList.x = x + 25 * sizeModifier
	@scoresList.y = y + 300 * sizeModifier
	@scoresList.width = w - 50 * sizeModifier
	@scoresList.itemHeight = 36 * sizeModifier

	@menu\update dt

	@scoresList\update dt

state.keypressed = (key, scanCode, ...) =>
	if data.isMenuInput key, "back"
		@manager\setState require "ui.menu"
	else
		@menu\keypressed key, scanCode, ...

state

