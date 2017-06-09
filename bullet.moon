
Entity = require "entity"

class extends Entity
	new: (arg) =>
		arg or= {}

		super.__init @, arg

		@player = arg.player or nil
		@damage = arg.damage or 1
		@damageType = arg.damageType or "bullet"

	__tostring: => "<Bullet: frame #{@frame}>"

