
---
-- Class to store stage-wide data and update code.
--
-- An instance of Stage is supposed to be able to generate its own entities
-- (enemies, random bullets, etc.) and draw its own background and overlay.
--
-- @classmod Stage

class
	---
	-- Stages constructor.
	--
	-- @param arg {}
	-- @param arg.title  Stage's title.
	-- @param arg.subtitle  Stage's subtitle.
	-- @param arg.update  Custom code to execute on update.
	-- @param arg.drawBackground  Background drawing function.
	-- @param arg.draw  Overlay drawing function. See `draw`.
	-- @param arg.drawTitle  Title drawing function.
	-- @param arg.drawBossDatva  Boss overlay drawing function.
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

	---
	-- Update function.
	update: =>
		@frame += 1

		if @frameEvents[@frame]
			@frameEvents[@frame] @game, self

		if @onUpdate
			@.onUpdate @game, self

		if @boss and @boss.readyForRemoval
			@boss = nil

	---
	-- Used by `Danmaku.draw` to draw the game's background.
	--
	-- It is called before anything else from the game has been drawn.
	drawBackground: =>
		if @onDrawBackground
			@\onDrawBackground!

	---
	-- Draw method.
	--
	-- Draws the title and the current boss’ data (if any).
	--
	-- This method is called after all other entities of the game have been
	-- drawn.
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

