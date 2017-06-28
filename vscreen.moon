
-- A virtual-screen of fixed resolution, that resizes itself (or at least
-- tools to resize it) when the real screen or window is bigger!

{
	width: 960
	height: 750
	rectangle: {
		x: 0
		y: 0
		w: 960
		h: 750
		sizeModifier: 1
	}
	fullRectangle: {
		x: 0
		y: 0
		w: 1024
		h: 800
		sizeModifier: 1
	}

	update: =>
		w, h = love.graphics.getWidth!, love.graphics.getHeight!

		hratio = w / @width
		vratio = h / @height

		sizeModifier = math.max 1, math.min hratio, vratio

		@sizeModifier = sizeModifier

		@rectangle = {
			x: (w - @width * sizeModifier) / 2
			y: (h - @height * sizeModifier) / 2
			w: @width * sizeModifier
			h: @height * sizeModifier
			:sizeModifier
		}

		@fullRectangle = {
			x: 0
			y: 0
			:w, :h
			:sizeModifier
		}

		@rectangle, @fullRectangle

state


}

