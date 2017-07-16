
Entity = require "danmaku.entity"
Enemy = require "danmaku.enemy"

class extends Enemy
	new: (arg) =>
		arg or= {}

		Enemy.__init self, arg

		@disableTimeoutRemoval = true

		@name = arg.name or "???"
		@touchable = arg.touchable or false

		@onEndOfSpell = arg.endOfSpell or ->

		-- Number of frames the boss should wait between two spellcards.
		@interSpellDelay = arg.interSpellDelay or 180

		@spellcards = {}
		for i = 1, #arg
			spell = arg[i]

			if type(spell) == "table"
				table.insert @spellcards, spell

		@spellSuccess = true

		@currentSpell = false
		@currentSpellIndex = 0
		@spellStartFrame = 0
		@spellEndFrame = 0
		@spellEndHealth = 0

	update: =>
		@\doUpdate =>
			if @frame == 0
				-- Recalculating lives and trimming incompatible spellcards.
				@lives = 0
				newSpellcards = {}
				for spell in *@spellcards
					unless spell\playableAtDifficulty @game.difficulty
						print "Skipping #{spell} due to difficulty."
						continue

					if spell.endOfLife or spell == @spellcards[#@spellcards]
						@lives += 1

					table.insert newSpellcards, spell

				@spellcards = newSpellcards

			currentSpell = @spellcards[@currentSpellIndex]

			if currentSpell
				if @health <= @spellEndHealth
					@\switchToNextSpell!
				elseif @frame == @spellStartFrame
					@damageable = true
					currentSpell.update self
					@speed = 0

					-- Should have moved there already, but this fixes
					-- rounding errors.
					{:x, :y} = @\getPosition self
					@x, @y = x, y
				elseif @frame == @spellEndFrame
					@spellSuccess = false

					@\switchToNextSpell!
				elseif @frame >= @spellStartFrame
					currentSpell.update self
			else
				if @currentSpellIndex == 0
					-- Before first spell…
					-- FIXME: hardcoded value.
					if @frame == 60
						@game\setBoss self

						@\switchToNextSpell!

					true
				else
					-- After last spell…
					print "last spell done"

				-- Used only when not dealing with spellcards.
				if @onUpdate
					@\onUpdate!

	switchToNextSpell: =>
		if @currentSpell
			if @onEndOfSpell
				@\onEndOfSpell @currentSpell

		@game\clearScreen!

		if @currentSpellIndex > 0
			difference = @spellEndFrame - @frame

			-- Jumping into the future~
			@frame += difference
			@game.frame += difference

		oldSpell = @spellcards[@currentSpellIndex]


		@currentSpellIndex += 1
		@touchable = true

		-- FIXME: WHY DOES IT HAVE TO TAKE TWO LINES? I hate you.
		while @spellcards[@currentSpellIndex] and not @spellcards[@currentSpellIndex]\playableAtDifficulty @game.difficulty
			print "Skipping #{@spellcards[@currentSpellIndex]}"
			@currentSpellIndex += 1

		spell = @spellcards[@currentSpellIndex]

		@currentSpell = spell

		if spell
			if oldSpell and oldSpell.endOfLife
				@lives -= 1

			-- We're resetting the health after any kind of attack in
			-- case there was a slight damage overflow.
			health = 0

			index = @currentSpellIndex
			while @spellcards[index] and not @spellcards[index].endOfLife
				health += @spellcards[index].health
				index += 1

			@health = health
			@spellEndHealth = health - spell.health

			if not oldSpell or oldSpell.endOfLife
				@maxHealth = health

			@spellStartFrame = @frame + @interSpellDelay
			@spellEndFrame = @frame + spell.timeout + @interSpellDelay

			@\moveTowardsPosition @\getPosition!

			@damageable = false
		else -- end of spellcards list
			@health = 1

		@spellSuccess = true

	getPosition: =>
		if spell and spell.position
			spell.position self
		else
			{x: @x, y: @y}

	moveTowardsPosition: (position) =>
		distance = Entity.distance self, position
		angle = math.atan2 position.y - @y,
			position.x - @x

		@speed = distance / @interSpellDelay
		@angle = angle

	roam: (arg) =>
		interval      = arg.interval   or 60
		pauseDuration = arg.pauseDuration or 60
		borderSize    = arg.borderSize or 80

		frame = @frame - @spellStartFrame

		print frame

		switch frame % (interval + pauseDuration)
			when 0
				x = math.random borderSize, @game.width - borderSize
				y = math.random borderSize, 1/3 * @game.height

				dx = x - @x
				dy = y - @y

				@direction = math.atan2 dy, dx
				@speed = Entity.distance(self, {:x, :y}) / interval
			when interval
				@speed = 0

	die: =>
		if @spellcards[@currentSpellIndex]
			@\switchToNextSpell!
		else
			@game\setBoss nil
			super\die!

	__tostring: =>
		"<Boss: #{@name}, frame #{@frame}>"

