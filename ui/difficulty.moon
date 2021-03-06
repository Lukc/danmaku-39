
state = {}

{:Danmaku} = require "danmaku"

data = require "data"
fonts = require "fonts"
vscreen = require "vscreen"

Menu = require "ui.tools.menu"

drawSelector = (x, y) =>
	@height = vscreen.rectangle.sizeModifier * @baseHeight

	r = @\getRectangle x, y
	color = switch @value
		when "Tutorial"
			{63, 191, 255}
		when "Easy"
			{127, 255, 255}
		when "Normal"
			{127, 255, 127}
		when "Hard"
			{255, 191,  95}
		when "Lunatic"
			{255,  95, 191}
		when "Ultra Lunatic"
			{255, 31, 127}
		when "Extra"
			{255, 63, 63}
		when "Ultra Extra"
			{255, 31, 127}
		when "Last Word"
			{127, 127, 127}
		when "Extra Last Word"
			{63, 63, 63}
		else
			{255, 255, 255}

	if @\hovered!
		for i = 1, 3
			if color[i] < 255
				color[i] += -16 + 32 * math.sin @menu.drawTime * 5

	love.graphics.setColor color
	love.graphics.rectangle "fill", r.x, r.y, r.w, r.h

	value = tostring @value

	bigFont = fonts.get "Sniglet-Regular", 72 * vscreen.sizeModifier

	w = bigFont\getWidth value
	h = bigFont\getHeight value

	@menu\print value, r.x + (r.w - w) / 2, r.y + (r.h - h) / 2,
		{255, 255, 255}, bigFont

	love.graphics.setFont bigFont

	love.graphics.print "<", r.x - 36 * vscreen.sizeModifier, r.y + (r.h - h - 10) / 2
	love.graphics.print ">", r.x + 6 * vscreen.sizeModifier + r.w, r.y + (r.h - h - 10) / 2

drawCheck = (x, y) =>
	{:sizeModifier} = vscreen.rectangle

	@height = sizeModifier * @baseHeight

	font = fonts.get "Sniglet-Regular", 36 * sizeModifier

	r = @\getRectangle x, y

	color = if @value
		{95, 255, 95}
	else
		{255, 95, 95}

	if @\hovered!
		for i = 1, 3
			if color[i] < 255
				color[i] += -32 + 64 * math.sin @menu.drawTime * 5

	love.graphics.setColor color

	with w = font\getWidth @label
		y = r.y + r.h / 2
		love.graphics.setLineWidth 2 * sizeModifier
		love.graphics.line r.x + w + 48 * sizeModifier, y,
			r.x + r.w - (96 + 16) * sizeModifier, y
		love.graphics.setLineWidth 1

	love.graphics.rectangle "fill",
		r.x + r.w - 96 * sizeModifier,
		r.y + 16 * sizeModifier,
		64 * sizeModifier, 64 * sizeModifier

	love.graphics.setColor 127, 127, 127
	love.graphics.rectangle "line",
		r.x + r.w - 96 * sizeModifier, r.y + 16 * sizeModifier,
		64 * sizeModifier, 64 * sizeModifier

	@menu\print @label, r.x + 32, r.y + 20 * sizeModifier, color, font

play = =>
	options = {
		stage: state.stage
		noBombs: state.noBombs
		pacific: state.pacific
		training: state.training
		difficulty: Danmaku.Difficulties[state.difficulty]
		startingPower: state.training and 25 or state.startingPower or 0
	}

	state.manager\setState require("ui.character"), options, state.multiplayer

state.enter = (stage, noReset) =>
	if noReset
		return

	@stage = stage
	@multiplayer = false

	@noBombs = false
	@pacific = false
	@training = false

	@startingPower = if stage.generated
		25
	else
		false

	@difficulty = Danmaku.getDifficultyString(stage.difficulties[1])

	@menu = Menu {
		font: fonts.get "Sniglet-Regular", 32

		x: 150
		y: 200

		{
			type: "selector"
			values: [Danmaku.getDifficultyString(d) for d in *stage.difficulties]
			label: state.difficulty
			noTransition: true
			baseHeight: 128
			draw: drawSelector
			onSelection: play
			onValueChange: (item) =>
				print item.value
				state.difficulty = item.value
		}
		{height: 32}
		{
			type: "check"
			label: "Training"
			noTransition: true
			baseHeight: 96
			draw: drawCheck
			onSelection: play
			onValueChange: (item) =>
				state.training = item.value
		}
		{
			type: "check"
			label: "Pacific"
			noTransition: true
			baseHeight: 96
			draw: drawCheck
			onSelection: play
			onValueChange: (item) =>
				state.pacific = item.value
				state.noBombs = item.value
		}
		{
			type: "check"
			label: "Multiplayer"
			noTransition: true
			baseHeight: 96
			draw: drawCheck
			onSelection: play
			onValueChange: (item) =>
				print self, item, item.value
				state.multiplayer = item.value
		}
	}

state.keypressed = (key, scanCode, ...) =>
	if key == "escape" or key == "tab"
		return @manager\setState require("ui.menu"), nil, nil, true

	@menu\keypressed key, scanCode, ...

state.gamepadpressed = (joystick, button) =>
	if button == data.config.menuGamepadInputs.back
		return @manager\setState require("ui.menu"), nil, nil, true

	@menu\gamepadpressed joystick, button

state.update = (dt) =>
	@menu\update dt

state.draw = =>
	{:x, :y, sizeModifier: modifier, :w, :h} = vscreen\update!

	@menu.x = x + 150 * modifier
	@menu.y = y + 200 * modifier

	@menu.width = w - (150 * 2) * modifier

	@menu\draw!

state

