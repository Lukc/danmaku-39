
data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
	gridWidth: 1
	gridHeight: 3
}

-- FIXME: Resize that grid dynamically.
getCharacterRectangle = (i) ->
	w = 300 / state.gridWidth
	h = 780 / state.gridHeight
	{
		x: 10 + ((i - 1) % state.gridWidth) * w
		y: 10 + (math.ceil(i / state.gridWidth) - 1) * h
		:w
		:h
	}

state.enter = (stage) =>
	@selection = 1
	@stage = stage

	@gridWidth = 1
	@gridHeight = #data.players

	while #data.players / @gridWidth > 4
		@gridHeight = math.ceil(@gridHeight / 2)
		@gridWidth *= 2

state.draw = =>
	love.graphics.setFont @font

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@selectedCharacter = nil

	for i = 1, (@gridWidth * @gridHeight)
		index = i
		character = data.players[index]

		r = with getCharacterRectangle i
			.x += x
			.y += y

		unless character
			love.graphics.setColor 127, 127, 127, 63
			love.graphics.rectangle "fill", r.x, r.y, r.w, r.h

		love.graphics.setColor 255, 255, 255
		love.graphics.rectangle "line", r.x, r.y, r.w, r.h

		if @selection == index
			if character
				@selectedCharacter = character

			love.graphics.setColor 255, 191, 127
			for j = 1.5, 4.5
				love.graphics.rectangle "line",
					r.x + j, r.y + j, r.w - 2*j, r.h - 2*j

	if @selectedCharacter
		love.graphics.rectangle "line",
			x + 1024 - 320 - 10, y + 10, 320, 780

		character = @selectedCharacter

		love.graphics.print "#{character.name}",
			x + 1024 - 320 + (320 - @font\getWidth character.name) / 2, y + 10
		love.graphics.print "#{character.title}",
			x + 1024 - 320 + (320 - @font\getWidth character.title) / 2, y + 50

		love.graphics.print "#{character.mainAttackName}",
			x + 1024 - 320, y + 120
		love.graphics.print "#{character.secondaryAttackName}",
			x + 1024 - 320, y + 160

state.keypressed = (key, scancode, ...) =>
	x = (@selection - 1) % @gridWidth + 1
	y = math.floor((@selection - 1) / @gridWidth) + 1

	getWidth = (y) ->
		if y <= math.floor(#data.players / @gridWidth)
			@gridWidth
		else
			(#data.players - 1) % @gridWidth + 1

	getHeight = (x) ->
		h = math.floor(#data.players / @gridWidth)
		if #data.players % @gridWidth >= x
			h += 1
		h

	if key == "escape"
		@manager\setState require("ui.menu"), true
	elseif key == "return"
		if @selectedCharacter
			@manager\setState require("ui.game"), @stage, {@selectedCharacter}
	elseif key == "down"
		y = (y - 0) % getHeight(x) + 1
	elseif key == "up"
		y = (y - 2) % getHeight(x) + 1
	elseif key == "left"
		x = (x - 2) % getWidth(y) + 1
	elseif key == "right"
		x = (x - 0) % getWidth(y) + 1

	print x,  y

	@selection = (y - 1) * @gridWidth + (x - 1) + 1

state

