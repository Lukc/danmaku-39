
ImageData = class
	new: (image) =>
		@sprite = image
		@age = 0

	update: (dt) =>
		@age += dt

	deprecate: (dt) =>
		@age += dt

		@deprecation or= 0
		@deprecation += dt

	draw: (portrait) =>
		unless @sprite
			return

		sizeRatio = portrait.width / @sprite\getWidth!
		sizeRatio = math.min sizeRatio, portrait.height / @sprite\getHeight!

		mirrorFactor = if portrait.mirrored
			-1
		else
			1

		alpha = 255
		alpha = math.min alpha, @age * 255

		if @deprecation
			alpha = math.min alpha, @deprecation * 255

		gray = 127 + alpha / 2
		love.graphics.setColor gray, gray, gray, alpha

		love.graphics.draw @sprite,
			portrait.x, portrait.y,
			nil,
			sizeRatio * mirrorFactor, sizeRatio,
			@sprite\getWidth!/2, @sprite\getHeight!/2

class
	new: (arg) =>
		arg or= {}

		@stack = {}

		@x = arg.x or 0
		@y = arg.y or 0

		@width = arg.width or 200
		@height = arg.height or 160

		@mirrored = arg.mirrored or false

		@\push nil

	push: (image) =>
		top = @stack[#@stack]

		if top and top.sprite == image
			return

		@stack[#@stack+1] = ImageData image

	update: (dt) =>
		for i = 1, #@stack
			imageData = @stack[i]

			if i == 1
				imageData\update dt
			else
				imageData\deprecate dt

		if #@stack > 1
			bottom = @stack[1]

			if bottom and bottom.deprecation and bottom.deprecation > 1
				table.remove @stack, 1

	draw: (dt) =>
		oldColor = {love.graphics.getColor!}

		for imageData in *@stack
			imageData\draw self

		love.graphics.setColor oldColor

