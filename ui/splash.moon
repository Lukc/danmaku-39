
state = {
	-- Will get loaded only once.
	time: 0
	endTime: 6
	particles: {}
	sprite: love.graphics.newImage "data/art/splash_bullet.png"
	font: love.graphics.newFont "data/fonts/miamanueva.otf", 192
	smallFont: love.graphics.newFont "data/fonts/miamanueva.otf", 36
}

state.enter = =>
	w = love.graphics.getWidth!
	h = love.graphics.getHeight!

	x = (w - 1024) / 2
	y = (h - 800) / 2

	do
		n = 40
		for i = 1, n
			angle = math.pi * 2 * math.random!
			dx = 0.1 * math.cos angle
			dy = 0.1 * math.sin angle

			table.insert @particles, {
				x: math.random x, x + 1024
				y: 800/2 + math.random -400, 400
				radius: 2^math.random 1, 6
				type: "growing"
				start: math.random! * 1.5
				duration: 1 + math.random! * 3
				color: {191, 191, 191}
				:dx, :dy
			}

	do
		n = 400
		for i = 1, n
			maxDistance = math.random(1, math.random(1, 64))

			table.insert @particles, {
				x: 1024 * (n - i) / n + math.random -48, 48
				y: 800/2 + math.random -maxDistance, maxDistance
				radius: 8 + math.random 1, 8
				color: {255, 255, 255}
				type: "shrinking"
				start: (n - i) / n * 1.5
				duration: 0.25
			}

	do
		n = 150
		for i = 1, n
			maxDistance = math.random(1, math.random(1, math.random(1, 36))) * 6

			angle = math.pi + (math.random! - 0.5) * math.pi / 4
			dx = math.cos angle
			dy = math.sin angle

			table.insert @particles, {
				x: 1024 * (n - i) / n + math.random -maxDistance, maxDistance
				y: 800/2 + math.random -maxDistance, maxDistance
				radius: 4 + math.random 2, 8
				color: {math.random(191, 255), math.random(127, 191), math.random(127, 191)}
				type: "shrinking"
				start: (n - i) / n * 1.5
				duration: 1 + math.random! * 3
				:dx
				:dy
			}

state.draw = =>
	sw, sh = @sprite\getWidth!, @sprite\getHeight!

	x = (love.graphics.getWidth! - 1024) / 2
	y = (love.graphics.getHeight! - 800) / 2

	alpha = math.min 255, 255 * @time
	alpha = math.min alpha, 255 * (@endTime - @time)

	love.graphics.setLineWidth 400
	love.graphics.setColor 16, 9, 9, alpha
	love.graphics.line x + @time / 32 * 400 + 200, love.graphics.getHeight! + 200,
		x + @time / 32 * 400 + 600, -200

	for particle in *@particles
		if @time >= particle.start
			endTime = math.min @endTime, particle.start + particle.duration or 0

			r, g, b = unpack particle.color or {255, 255, 255}

			a = 255 * math.min 1, (@time - particle.start)

			if @time >= endTime - 0.5
				a = math.min a, 255 * math.min 1, (endTime - @time) / 0.5

			love.graphics.setColor r, g, b, a

			scale = particle.radius / sw * 4
			love.graphics.draw @sprite, x + particle.x, y + particle.y, nil, scale, scale, sw/2, sh/2

	do
		text = "Splash~"

		love.graphics.setFont @font
		love.graphics.setColor 255, 255, 255, alpha

		with x = x + (1024 - @font\getWidth text) / 2
			with y = y + 100
				love.graphics.setColor 0, 0, 0, alpha
				love.graphics.print text, x + 4, y + 2
				love.graphics.print text, x + 2, y + 4
				love.graphics.print text, x + 4, y + 4

				love.graphics.setColor 255, 255, 255, alpha
				love.graphics.print text, x, y

	do
		text = "Development Build - Week 1"

		love.graphics.setFont @smallFont
		love.graphics.setColor 127, 127, 127, alpha

		with x = x + 1024 - @smallFont\getWidth(text) - 150
			with y = y + 800 - @smallFont\getHeight(text) - 125
				love.graphics.setColor 0, 0, 0, alpha
				love.graphics.print text, x + 4, y + 2
				love.graphics.print text, x + 2, y + 4
				love.graphics.print text, x + 4, y + 4

				love.graphics.setColor 255, 255, 255, alpha
				love.graphics.print text, x, y

state.update = (dt) =>
	@time += dt

	removables = {}

	for particle in *@particles
		if @time >= particle.start
			if particle.type == "growing"
				particle.radius += dt * 6
			elseif particle.type == "shrinking"
				particle.radius -= dt * 4

				if particle.radius <= 0
					table.insert removables, particle
					particle.radius = 0

			if particle.dx
				particle.x += particle.dx
			if particle.dy
				particle.y += particle.dy

			if @time >= particle.start + particle.duration
				table.insert removables, particle

	for j = 1, #removables
		item = removables[j]

		for i = 1, #@particles
			if @particles[i] == item
				table.remove @particles, i

				j -= 1

				break

	if @time >= @endTime
		love.graphics.setLineWidth 1
		@manager\setState require "ui.menu"

state.keypressed = (key, scanCode, ...) =>
	print key, scanCode
	for e in *{"escape", "space", "return", "z"}
		if scanCode == e
			if @endTime - @time > 1
				@endTime = @time + 1

state

