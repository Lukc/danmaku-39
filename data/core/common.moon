
items = require "data.items"

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

{
	titleFont: love.graphics.newFont 42
	subtitleFont: love.graphics.newFont 24

	:circularDrop

	drawBossData: =>
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

