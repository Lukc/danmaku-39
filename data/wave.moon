
Wave =
	new: (arg) ->
		arg or= {}

		{
			name:     arg.name -- probably won’t be used.
			start:    arg.start or 120
			interval: arg.interval or 120
			count:    arg.count or 1
			doThings: arg[1] or =>
		}

	toUpdate: (waves) ->
		eventsByFrame = {}

		for wave in *waves
			for i = 1, wave.count
				frame = wave.start + (i - 1) * wave.interval

				unless eventsByFrame[frame]
					eventsByFrame[frame] = {}

				table.insert eventsByFrame[frame], =>
					wave.doThings self, i

		=>
			for event in *eventsByFrame[@frame] or {}
				print event, @frame, self
				event self

setmetatable Wave, {
	__call: (...) =>
		Wave.new ...
}

