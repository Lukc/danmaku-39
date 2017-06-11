
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

		@onDrawBackground = arg.drawBackground
		@onDraw = arg.draw

		@drawTitle = arg.drawTitle or =>
			love.graphics.setColor 200, 200, 200
			love.graphics.print @title, 40, 0
			love.graphics.print @subtitle, 40,  20

		@drawBossData = arg.drawBossData or =>
			font = love.graphics.getFont!

			love.graphics.setColor 255, 255, 255
			love.graphics.print @boss.name,
				@game.width - font\getWidth(@boss.name) - 20, 20

	-- game: Danmaku
	update: =>
		@frame += 1

		if @frameEvents[@frame]
			@frameEvents[@frame] @game, self

		if @onUpdate
			@.onUpdate @game, self

		if @boss
			entity = @boss.entity

			if entity.readyForRemoval
				@boss = nil

	drawBackground: =>
		if @onDrawBackground
			@\onDrawBackground!

	draw: =>
		-- FIXME: There are constants that should be configurable, here…
		if @frame <= 180
			@\drawTitle!

		if @boss
			@\drawBossData!

		if @onDraw
			@\onDraw!

	setBoss: (data) =>
		@boss = data

	__tostring: => "<Stage: frame #{@frame}>"

