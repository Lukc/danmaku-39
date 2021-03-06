
---
-- A class that represents a game of danmaku.
--
-- Its purpose is to store, update and draw a set of entities (`Entity`),
-- removing them and creating them as needed or requested by the game scripts
-- it is provided.
--
-- @see Entity
-- @classmod Danmaku

Entity = require "danmaku.entity"
Bullet = require "danmaku.bullet"
Item = require "danmaku.item"
Enemy = require "danmaku.enemy"
Player = require "danmaku.player"
Boss = require "danmaku.boss"

class
	---
	-- Generic constructor.
	--
	-- All parameters are optionnal and have sane default values.
	--
	-- @param arg {}
	-- @param arg.x   The x-position at which to draw the game with `\draw`
	-- @param arg.y   The y-position at which to draw the game with `\draw`
	-- @param arg.width   Width of the game area.
	-- @param arg.height  Height of the game area.
	-- @param arg.stage   The `Stage` to play.
	new: (arg) =>
		arg or= {}

		@x = arg.x or 0
		@y = arg.y or 0

		@width = arg.width or 600
		@height = arg.height or 750

		@drawWidth = arg.drawWidth or @width
		@drawHeight = arg.drawHeight or @height

		@players = {}
		@enemies = {}
		@playerBullets = {}
		@bullets = {}
		@items = {}
		@particles = {}

		-- Should contain all of the above, or something like that.
		@entities = {}

		-- Total, common score shared by all players.
		@score = 0

		@currentStage = arg.stage
		@currentStage.game = self

		@frame = 0

		-- For reference. Will be a reference to a Boss.
		@boss = nil

		@endReached = false

		@difficulty = arg.difficulty or 2

		@noBombs = arg.noBombs or false
		@pacific = arg.pacific or false
		@training = arg.training or false

	@Difficulties: {
		Tutorial: 0
		Easy:     1
		Normal:   2
		Hard:     3
		Lunatic:  4
		"Ultra Lunatic":  5
		Extra:    10
		"Ultra Extra":    11
		"Last Word": 12
		"Extra Last Word": 13
	}

	@getDifficultyString: (i) ->
		for k,v in pairs @@Difficulties
			if v == i
				return k

	@DifficultyStrings: do
		t = {}

		for i = 0, @@Difficulties["Extra Last Word"]
			difficulty = @@.getDifficultyString i

			if difficulty
				table.insert t, difficulty

		t

	difficultyString: (difficulty = @difficulty) =>
		for key, value in @@Difficulties
			if value = difficulty
				return key

		-- Well, we DID need a default value, right?
		return "Undiscovered Country"

	---
	-- Draws the game at the requested `x` and `y` coordinates.
	draw: =>
		oldColor = {love.graphics.getColor!}
		oldCanvas = love.graphics.getCanvas!
		canvas = love.graphics.newCanvas @width, @height
		canvas\setFilter "nearest", "nearest"
		love.graphics.setCanvas canvas

		love.graphics.rectangle "line", 0.5, 0.5, @width - 1, @height - 1

		if @currentStage
			@currentStage\drawBackground self

			love.graphics.setColor 255, 255, 255, 255

		for collection in *{@players, @enemies, @playerBullets, @bullets, @items, @particles}
			for entity in *collection
				entity\draw!

		if @currentStage
			@currentStage\draw self

		love.graphics.setCanvas oldCanvas

		love.graphics.setColor oldColor
		love.graphics.draw canvas, @x, @y, nil,
			@drawWidth / @width, @drawHeight / @height

	---
	-- Updates the game.
	--
	-- It is noteworthy that the delta-time provided by love or other tools
	-- are ignored. This is done so that the framerate becomes the speed of
	-- the game, and so that the game becomes more easily repeatable.
	--
	-- Repeatable games are needed to print replays, for online play, and
	-- possibly for other uses.
	update: =>
		@frame += 1

		if @currentStage
			@currentStage\update self

		for entity in *@entities
			entity\update!

		-- FIXME: This section is too procedural and not OO.
		for player in *@players
			for enemy in *@enemies
				if player\collides enemy
					player\inflictDamage 1, "collision"
					enemy\inflictDamage 1, "collision"

					player.entitiesCollidedWith[enemy] = player.interCollisionDuration

			for item in *@items
				if item\collides player
					item\collected player

			for bullet in *@bullets
				radius = player.radius
				touchable = player.touchable

				player.radius = player.grazeRadius
				player.touchable = true

				if player\collides bullet
					player.radius = radius
					player.touchable = touchable

					if player\collides bullet
						player\inflictDamage 1, bullet.damageType
						bullet\inflictDamage 1, "collision"

						player.entitiesCollidedWith[bullet] = player.interCollisionDuration
					else
						player\grazeBullet bullet

				player.radius = radius
				player.touchable = touchable

		for bullet in *@playerBullets
			for enemy in *@enemies
				if bullet\collides enemy
					enemy\inflictDamage bullet.damage, bullet.damageType
					bullet\inflictDamage 1, "collision"

					if enemy.dying
						bullet.player.score += enemy.score
						@score += enemy.score

		for particle in *@particles
			particle\update!

		for name in *{"entities", "players", "playerBullets", "enemies", "bullets", "items", "particles"}
			collection = self[name]

			self[name] = with _ = {}
				for entity in *collection
					if not entity.readyForRemoval
						table.insert _, entity

	---
	-- Adds an `Entity` to the game.
	--
	-- Entities are identified based on their class: players are instances of
	-- `Player`, bullets of `Bullet`, and enemies of `Enemy`.
	--
	-- Direct instances of `Entity` are also added, but no collision detection
	-- is made on them.
	--
	-- Also of note is that `Bullet`s are distinguished between player bullets
	-- and enemy bullets based on their `.player` field.
	addEntity: (entity) =>
		switch entity.__class
			when Bullet
				if entity.player
					table.insert @playerBullets, entity
				else
					table.insert @bullets, entity
			when Player
				table.insert @players, entity
			when Enemy, Boss
				table.insert @enemies, entity
			when Item
				table.insert @items, entity
			when Entity
				table.insert @particles, entity

		table.insert @entities, entity

		entity.game = self

		entity\update!

		entity

	clearScreen: =>
		for collection in *{@bullets, @enemies}
			for entity in *collection
				if entity.__class != Boss
					entity\die!

	endOfStage: =>
		@endReached = true

	-- Ain’t this a bit TOO stupid? Will we really have operations to add there?
	setBoss: (boss) =>
		@boss = boss

		@bossSince = if boss
			@frame

	failSpellcard: =>
		if @boss
			@boss.spellSuccess = false

	__tostring: => "<Danmaku: frame #{@frame}>"

