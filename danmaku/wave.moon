
class
	new: (arg) =>
		arg or= {}

		@name = arg.name or nil -- May not be used at all.
		@timeout = arg.timeout or 1
		@onUpdate = arg.update or =>
		@finished = arg.finished or nil

		@frame = 0

	update: (game) =>
		@frame += 1

		if @onUpdate
			@\onUpdate game

	isFinished: =>
		if @finished
			return @\finished! or false

		if @frame > @timeout
			return true

		false

	__tostring: =>
		"<Wave: #{@name and ("\""..@name.."\"") or "(unnamed)"}, frame #{@frame}>"

