
events = {
	"update", "draw",
	"keypressed", "keyreleased",
	"mousepressed", "mousemoved", "mousereleased",
	"gamepadpressed", "gamepadreleased",
	"joystickpressed", "joystickreleased",
	"lowmemory"
}

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
		for event in *events
			table[event] = (...) ->
				self[event] self, ...

	self

{
	:Manager
}

