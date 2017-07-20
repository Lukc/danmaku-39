
items = require "data.items"

fonts = require "fonts"

circularDrop = (entity, count, radius, constructor) ->
	for i = 1, count
		a = math.pi * 2 / count * i

		x = entity.x + radius * math.cos a
		y = entity.y + radius * math.sin a

		entity.game\addEntity constructor
			:x, :y

{
	titleFont: love.graphics.newFont 42
	subtitleFont: love.graphics.newFont 24

	:circularDrop

	drawBossData: =>
		with x, y = @boss.x, @boss.y
			f = @boss.frame - @bossSince
			fm = math.min 1, f / 60 -- frame modifier, for starting animations.

			radius = 20 + (80 - 20) * fm
			width = 7

			alpha = 255 * fm

			love.graphics.setLineWidth width

			startHealth = @boss.maxHealth
			endHealth = @boss.maxHealth
			for spellcard in *@boss.spellcards
				endHealth = startHealth - spellcard.health

				print startHealth, endHealth, @boss.health

				if @boss.health > endHealth
					if spellcard.name
						love.graphics.setColor 255, 191, 211, alpha
					else
						love.graphics.setColor 255, 255, 255, alpha

					love.graphics.arc "line", "open",
						x, y, radius,
						-math.pi / 2 - 2 * math.pi * math.min(startHealth, @boss.health) / @boss.maxHealth,
						-math.pi / 2 - 2 * math.pi * (endHealth) / @boss.maxHealth

				startHealth -= spellcard.health
			love.graphics.setLineWidth 1.5

			love.graphics.setColor 255, 63, 63, alpha
			love.graphics.circle "line", x, y, radius + width/2
			love.graphics.circle "line", x, y, radius - width/2

			love.graphics.setLineWidth 3
			health = @boss.maxHealth
			for spell in *@boss.spellcards
				if spell.endOfLife or spell == @boss.spellcards[#@boss.spellcards]
					break

				health -= spell.health
				angle = -math.pi/2 - math.pi * 2 * (health / @boss.maxHealth) * fm

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

		font = fonts.get "miamanueva", 24
		love.graphics.setFont font

		love.graphics.setColor 255, 255, 255
		with x = @width - 40 - font\getWidth tostring @boss.name
			love.graphics.print "#{@boss.name}", x, 20

		spell = @boss.currentSpell
		if spell and spell.name
			font = fonts.get "miamanueva", 18
			love.graphics.setFont font

			with x = @width - 40 - font\getWidth tostring spell.name
				love.graphics.print "#{spell.name}", x, 70

			if @boss.frame >= @boss.spellStartFrame
				timeout = math.floor (@boss.spellEndFrame - @boss.frame) / 60
				timeout = tostring timeout

				font = fonts.get "miamanueva", 32

				love.graphics.setFont font
				love.graphics.print timeout, 32, 20
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

