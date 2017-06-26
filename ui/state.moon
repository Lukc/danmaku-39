
events = {
	"update", "draw",
	"keypressed", "keyreleased",
	"mousepressed", "mousemoved", "mousereleased",
	"gamepadpressed", "gamepadreleased",
	"joystickpressed", "joystickreleased",
	"lowmemory"
}

frameDuration = 1 / 60

Manager = ->
	self = {}

	-- FIXME: Many more events are still missing.
	for event in *events
		self[event] = (...) =>
			if @currentState and @currentState[event]
				@currentState[event] @currentState, ...

	self.setState = (state, ...) =>
		if @currentState and @currentState.leave
			@currentState.leave @currentState

		@currentState = state
		@currentState.manager = self

		if @currentState and @currentState.enter
			@currentState.enter @currentState, ...

	self.bindEvents = (table) =>
		time = 0
		oldEvent = table[event]

		for event in *events
			if event == "update"
				table.update = (dt) ->
					time += dt

					while time >= frameDuration
						self\update dt

						time -= frameDuration
			else
				table[event] = (...) ->
					self[event] self, ...

	self

{
	:Manager
}

