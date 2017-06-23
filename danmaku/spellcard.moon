
class
	new: (arg) =>
		arg or= {}

		@health = arg.health or 100
		@timeout = arg.timeout or 30 * 60
		@update = arg.update or =>

		-- Whether defeating the spellcard means the boss will lose a life.
		@endOfLife = arg.endOfLife or false

		-- Only named spellcards are true spellcards.
		@name = arg.name or nil
		@description = arg.description or nil

		@difficulties = [difficulty for difficulty in *(arg.difficulties or {})]

		@position = arg.position

