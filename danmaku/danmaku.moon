
Entity = require "danmaku.entity"
Bullet = require "danmaku.bullet"
Enemy = require "danmaku.enemy"
Player = require "danmaku.player"

class
	new: (arg) =>
		arg or= {}

		@x = arg.x or 0
		@y = arg.y or 0

		@width = arg.width or 600
		@height = arg.height or 800

		@players = {}
		@enemies = {}
		@playerBullets = {}
		@bullets = {}

		-- Should contain all of the above, or something like that.
		@entities = {}

		@currentStage = arg.stage
		@currentStage.game = self

		@frame = 0

	draw: =>
		oldCanvas = love.graphics.getCanvas!
		canvas = love.graphics.newCanvas @width, @height
		love.graphics.setCanvas canvas

		love.graphics.rectangle "line", @x + 0.5, @y + 0.5, @width - 1, @height - 1

		if @currentStage
			@currentStage\drawBackground self

			love.graphics.setColor 255, 255, 255, 255

		for collection in *{@players, @enemies, @playerBullets, @bullets}
			for entity in *collection
				entity\draw!

		if @currentStage
			@currentStage\draw self

		love.graphics.setCanvas oldCanvas

		love.graphics.setColor 255, 255, 255
		love.graphics.draw canvas, @x, @y

	update: =>
		@frame += 1

		if @currentStage
			@currentStage\update self

		for entity in *@entities
			entity\update!

		for player in *@players
			for enemy in *@enemies
				if player\collides enemy
					player\inflictDamage 1, "collision"
					enemy\inflictDamage 1, "collision"

			for bullet in *@bullets
				if player\collides bullet
					player\inflictDamage 1, bullet.damageType
					bullet\inflictDamage 1, "collision"

		for bullet in *@playerBullets
			for enemy in *@enemies
				if bullet\collides enemy
					enemy\inflictDamage bullet.damage, bullet.damageType
					bullet\inflictDamage 1, "collision"

					print "BOOM"

		for name in *{"entities", "players", "playerBullets", "enemies", "bullets"}
			collection = self[name]

			self[name] = with _ = {}
				for entity in *collection
					if not entity.readyForRemoval
						table.insert _, entity

	addEntity: (entity) =>
		switch entity.__class
			when Bullet
				if entity.player
					table.insert @playerBullets, entity
				else
					table.insert @bullets, entity
			when Player
				table.insert @players, entity
			when Enemy
				table.insert @enemies, entity
			when Entity
				print "Adding generic entity to the game. wtf is going on?"

		table.insert @entities, entity

		entity.game = self

		entity\update!

		entity

	__tostring: => "<Danmaku: frame #{@frame}>"

