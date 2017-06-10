
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

		@boss = nil -- For reference.

	-- game: Danmaku
	update: (game) =>
		@frame += 1

		if @frameEvents[@frame]
			@frameEvents[@frame] game, self

		if @onUpdate
			@.onUpdate game, self

		if @boss
			entity = @boss.entity

			if entity.readyForRemoval
				@boss = nil

	draw: (game, where) =>
		{:x, :y} = where

		if @frame <= 90
			love.graphics.setColor 200, 200, 200
			love.graphics.print @title, x + 40, y
			love.graphics.print @subtitle, x + 40, y + 20

		if @boss
			font = love.graphics.getFont!

			love.graphics.setColor 255, 255, 255
			love.graphics.print @boss.name,
				game.width - font\getWidth(@boss.name) - 20, y + 20

	setBoss: (data) =>
		@boss = data

	__tostring: => "<Stage: frame #{@frame}>"

