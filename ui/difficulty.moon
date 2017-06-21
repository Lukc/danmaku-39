
state = {}

Menu = require "ui.tools.menu"

bigFont = love.graphics.newFont "data/fonts/miamanueva.otf", 72

drawSelector = (x, y) =>
	r = @\getRectangle x, y
	color = switch @value
		when "Normal"
			{127, 255, 127}
		when "Hard"
			{255, 191,  95}
		when "Lunatic"
			{255,  95, 191}
		else
			{255, 255, 255}

	if @\hovered!
		for i = 1, 3
			if color[i] < 255
				color[i] += -16 + 32 * math.sin @menu.drawTime * 5

	love.graphics.setColor color
	love.graphics.rectangle "fill", r.x, r.y, r.w, r.h

	w = bigFont\getWidth @value
	h = bigFont\getHeight @value

	@menu\print @value, r.x + (r.w - w) / 2, r.y + (r.h - h - 10) / 2 - 6,
		{255, 255, 255}, bigFont

	love.graphics.print "<", r.x - 32,   r.y + (r.h - h - 10) / 2
	love.graphics.print ">", r.x + r.w, r.y + (r.h - h - 10) / 2

drawCheck = (x, y) =>
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

	with w = @menu.font\getWidth @label
		y = r.y + r.h / 2
		love.graphics.line r.x + w + 48, y,
			r.x + r.w - 96 - 16, y

	love.graphics.rectangle "fill", r.x + r.w - 96, r.y + 16, 64, 64

	love.graphics.setColor 127, 127, 127
	love.graphics.rectangle "line", r.x + r.w - 96, r.y + 16, 64, 64

	@menu\print @label, r.x + 32, r.y, color

play = ->
	=>
		print "FIXME: Options and difficulty are not passed!"
		state.manager\setState require("ui.character"), state.stage, state.multiplayer

state.enter = (stage, noReset) =>
	if noReset
		return

	@stage = stage
	@multiplayer = false

	@menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32

		x: 200
		y: 200

		{
			type: "selector"
			values: {"Normal", "Hard", "Lunatic"}
			label: "Normal"
			noTransition: true
			height: 128
			draw: drawSelector
			onSelection: play!
		}
		{height: 32}
		{
			type: "check"
			label: "Training"
			noTransition: true
			height: 96
			draw: drawCheck
			onSelection: play!
		}
		{
			type: "check"
			label: "Pacific"
			noTransition: true
			height: 96
			draw: drawCheck
			onSelection: play!
		}
		{
			type: "check"
			label: "Multiplayer"
			noTransition: true
			height: 96
			draw: drawCheck
			onSelection: play!
			onValueChange: (item) =>
				print self, item, item.value
				state.multiplayer = item.value
		}
	}

state.keypressed = (key, scanCode, ...) =>
	if key == "escape" or key == "tab"
		return @manager\setState require("ui.menu"), nil, nil, true

	@menu\keypressed key, scanCode, ...

state.update = (dt) =>
	@menu\update dt

state.draw = =>
	@menu\draw!

state

