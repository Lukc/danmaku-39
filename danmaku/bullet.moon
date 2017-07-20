
---
-- Class for bullets and other projectiles fired by an `Enemy` or a `Player`.
--
-- @classmod Bullet

Entity = require "danmaku.entity"

class extends Entity
	---
	-- Bullet constructeur.
	--
	-- @param arg {}
	-- @param arg.player The `Player` who fired the bullet. May be nil.
	-- @param arg.damageType The type of damage the bullet will inflict.
	--  Defaults to "bullet".
	new: (arg) =>
		arg or= {}

		super.__init @, arg

		@player = arg.player or nil
		@damage = arg.damage or 1
		@damageType = arg.damageType or "bullet"

		@onCancellation = arg.cancellation

	cancel: =>
		@\die!

		if @onCancellation
			@\onCancellation!

	__tostring: => "<Bullet: frame #{@frame}>"

