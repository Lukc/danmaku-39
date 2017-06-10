
class
	new: (arg) =>
		arg or= {}

		@title = arg.title
		@subtitle = arg.subtitle

		@onUpdate = arg.update

		@frame = 0

		@frameEvents = {}
		for key, value in pairs arg
			if type(key) == "number"
				@frameEvents[key] = value

	-- game: Danmaku
	update: (game) =>
		@frame += 1

		if @frameEvents[@frame]
			@frameEvents[@frame] game, self

		if @onUpdate
			@.onUpdate game, self

	draw: (game, where) =>
		{:x, :y} = where

		if @frame <= 90
			love.graphics.setColor 200, 200, 200
			love.graphics.print @title, x + 40, y
			love.graphics.print @subtitle, x + 40, y + 20

