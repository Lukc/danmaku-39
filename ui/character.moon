
data = require "data"

state = {
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 24
}

getCharacterRectangle = (i) ->
	{
		x: 10
		y: 10 + (i - 1) * 110
		w: 320
		h: 110
	}

state.enter = (stage) =>
	@selection = 1
	@stage = stage

state.draw = =>
	love.graphics.setFont @font

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	@selectedCharacter = nil

	for i = 1, 7
		--index = i + (j - 1) * 6
		index = i
		character = data.players[index]

		r = with getCharacterRectangle i
			.x += x
			.y += y

		love.graphics.setColor 255, 255, 255
		love.graphics.rectangle "line", r.x, r.y, r.w, r.h

		if character
			love.graphics.print "#{character.name}", r.x + 10, r.y + 40

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
	if key == "return"
		if @selectedCharacter
			@manager\setState require("ui.game"), @stage, {@selectedCharacter}
	elseif key == "down"
		@selection = (@selection - 0) % #data.players + 1
	elseif key == "up"
		@selection = (@selection - 2) % #data.players + 1

state

