
items = require "data.items"

images = require "images"
fonts = require "fonts"

circularDrop = (entity, count, radius, constructor) ->
	for i = 1, count
		a = math.pi * 2 / count * i

		x = entity.x + radius * math.cos a
		y = entity.y + radius * math.sin a

		entity.game\addEntity constructor
			:x, :y

drawBossHealthBar = (entity) =>
	with x, y = entity.x, entity.y
		f = entity.frame - @bossSince
		fm = math.min 1, f / 60 -- frame modifier, for starting animations.

		radius = 20 + (80 - 20) * fm
		width = 7

		alpha = 255 * fm

		love.graphics.setLineWidth width

		startHealth = entity.maxHealth
		endHealth = entity.maxHealth
		for spellcard in *entity.spellcards
			endHealth = startHealth - spellcard.health

			if entity.health > endHealth
				if spellcard.name
					love.graphics.setColor 255, 191, 211, alpha
				else
					love.graphics.setColor 255, 255, 255, alpha

				love.graphics.arc "line", "open",
					x, y, radius,
					-math.pi / 2 - 2 * math.pi * math.min(startHealth, entity.health) / entity.maxHealth,
					-math.pi / 2 - 2 * math.pi * (endHealth) / entity.maxHealth

			startHealth -= spellcard.health
		love.graphics.setLineWidth 1.5

		love.graphics.setColor 255, 63, 63, alpha
		love.graphics.circle "line", x, y, radius + width/2
		love.graphics.circle "line", x, y, radius - width/2

		love.graphics.setLineWidth 3
		health = entity.maxHealth
		for spell in *entity.spellcards
			if spell.endOfLife or spell == entity.spellcards[#entity.spellcards]
				break

			health -= spell.health
			angle = -math.pi/2 - math.pi * 2 * (health / entity.maxHealth) * fm

			love.graphics.line x + math.cos(angle) * (radius - width / 2 + 1),
				y + math.sin(angle) * (radius - width / 2 + 1),
				x + math.cos(angle) * (radius + width / 2 - 1),
				y + math.sin(angle) * (radius + width / 2 - 1)

		do
			-- Topmost line.
			angle = -math.pi / 2
			love.graphics.line x + math.cos(angle) * (radius - width / 2 + 1),
				y + math.sin(angle) * (radius - width / 2 + 1),
				x + math.cos(angle) * (radius + width / 2 - 1),
				y + math.sin(angle) * (radius + width / 2 - 1)

		love.graphics.setLineWidth 1

drawMarker = do
	marker = images.get "marker_big.png"

	(color) =>
		love.graphics.setColor color
		love.graphics.draw marker,
			@x, @game.height, nil, nil, nil,
			marker\getWidth!/2, marker\getHeight!

drawSpellcardAnimation = =>
	str = "Spellcard attack!"

	frame = @boss.frame - @boss.spellStartFrame
	progress = frame / 120

	font = fonts.get "Sniglet-Regular", 64
	love.graphics.setFont font

	do
		ox = 100
		oy = 100
		alpha = 255

		if progress < 0.33
			alpha -= (1 - progress / 0.33) * 255

			p = math.sin(math.pi / 2 * (1 - progress / 0.33))

			ox -= p * 100
			oy += p * 100
		elseif progress > 0.66
			alpha -= (progress - 0.66) / 0.33 * 255

			p = math.sin(math.pi / 2 * (progress - 0.66) / 0.33)

			ox += p * 100
			oy -= p * 100

		love.graphics.setColor 240, 240, 255, alpha
		love.graphics.print str, ox, @height/2 - 100 + oy,
			-math.pi / 4

	font = fonts.get "Sniglet-Regular", 18
	love.graphics.setFont font

	alpha = 255 * 2 * if progress > 0.5
		1 - progress
	else
		progress

	if progress >= 0 and progress <= 1
		for i = 1, 19
			ox = (@width - font\getWidth str) / 2
			oy = i * @height / 19 + 72

			if i % 2 == 0
				ox += -50 * progress
				oy +=  50 * progress
			else
				ox +=  50 * progress
				oy += -50 * progress

			if i % 2 == 0
				ox += @width / 4
			if i % 3 == 0
				ox -= @width / 4
			if i % 4 == 0
				ox += @width / 4
			if i % 6 == 0
				ox -= @width / 4

			love.graphics.setColor 221, 221, 221, alpha
			love.graphics.print str,
				ox,
				oy,
				-math.pi/4

{
	titleFont: love.graphics.newFont 42
	subtitleFont: love.graphics.newFont 24

	:circularDrop

	drawBossData: =>
		spell = @boss.currentSpell
		if spell
			now = 1 - (@boss.frame - @boss.spellStartFrame) / spell.timeout
			d = 10 + 50 * now
			i = math.sin @frame / d

			drawMarker @boss, {
				255,
				63 + (255 - 63) / 2 * (1 + i),
				63 + (255 - 63) / 2 * (1 + i)
			}

			if spell.name
				drawSpellcardAnimation self

		drawBossHealthBar self, @boss

		font = fonts.get "miamanueva", 24
		love.graphics.setFont font

		love.graphics.setColor 255, 255, 255
		love.graphics.print "#{@boss.name}", 20, 20

		spell = @boss.currentSpell
		if spell and spell.name

			alpha = 255 * math.min 1, (@boss.frame - @boss.spellStartFrame) / 40

			love.graphics.setColor 255, 255, 255, alpha

			font = fonts.get "miamanueva", 18
			love.graphics.setFont font
			with x = @width - 70 - font\getWidth tostring spell.name
				love.graphics.print "#{spell.name}", x, 20

			font = fonts.get "miamanueva", 15
			love.graphics.setFont font
			with x = @width - 70 - font\getWidth "#{spell.sign} sign"
				love.graphics.print "#{spell.sign} sign", x, 50

			if @boss.frame >= @boss.spellStartFrame
				timeout = math.floor (@boss.spellEndFrame - @boss.frame) / 60
				timeout = tostring timeout

				font = fonts.get "miamanueva", 32

				love.graphics.setFont font
				love.graphics.print timeout, @width - 40 - font\getWidth(timeout) / 2, 20
	endOfSpell: (spell) =>
		local pointItems, item

		unless spell.name
			item = items.power
			pointItems = 0
		elseif @spellSuccess
			item = items.lifeFragment
			pointItems = 12
		else
			item = items.bombFragment
			pointItems = 8

		circularDrop self, pointItems, 64, items.point

		@game\addEntity item
			x: @x
			y: @y
}

