
Enemy = require "danmaku.enemy"

class extends Enemy
	new: (arg) =>
		arg or= {}

		Enemy.__init self, arg

		@disableTimeoutRemoval = true

		@name = arg.name or "???"
		@touchable = arg.touchable or false

		-- Number of frames the boss should wait between two spellcards.
		@interSpellDelay = arg.interSpellDelay or 180

		@spellcards = {}
		for i = 1, #arg
			spell = arg[i]

			if type(spell) == "table"
				table.insert @spellcards, spell

		@currentSpell = false
		@currentSpellIndex = 0
		@spellStartFrame = 0
		@spellEndFrame = 0
		@spellEndHealth = 0

		-- FIXME: Calculate this from spellcards count.
		@lives = 0
		for spell in *@spellcards
			if spell.endOfLife or spell == @spellcards[#@spellcards]
				@lives += 1

	update: =>
		@\doUpdate =>
			currentSpell = @spellcards[@currentSpellIndex]

			if currentSpell
				if @health <= @spellEndHealth
					@\switchToNextSpell!
				elseif @frame == @spellStartFrame
					@damageable = true
					currentSpell.update self
				elseif @frame >= @spellStartFrame
					currentSpell.update self
			else
				if @currentSpellIndex == 0
					-- Before first spell…
					-- FIXME: hardcoded value.
					if @frame == 60
						if @game.currentStage
							@game.currentStage\setBoss self

						@\switchToNextSpell!

					true
				else
					-- After last spell…
					print "last spell done"

				-- Used only when not dealing with spellcards.
				if @onUpdate
					@\onUpdate!

	switchToNextSpell: =>
		@game\clearScreen!

		if @currentSpellIndex > 0
			difference = @spellEndFrame - @frame
			print difference

			-- Jumping into the future~
			@frame += difference
			@game.frame += difference

		oldSpell = @spellcards[@currentSpellIndex]

		@currentSpellIndex += 1
		@touchable = true

		spell = @spellcards[@currentSpellIndex]

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

			@damageable = false
		else -- end of spellcards list
			@health = 1

		@currentSpell = spell

	die: =>
		if @spellcards[@currentSpellIndex]
			@\switchToNextSpell!
		else
			super\die!

