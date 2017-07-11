{
	:Entity,
	:Enemy,
	:Bullet,
	:Item,
	:Stage,
	:Boss,
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet} = require "data.bullets"
spellcards = require "data.spellcards"
items = require "data.items"
characters = require "data.characters"

{:circle, :laser} = require "data.helpers"

Wave = require "data.wave"
{:StageData, :ModData, :BossData} = require "data.checks"

fonts = require "fonts"

midboss4 = require "data.core.stage4.midboss"

boss4 = require "data.core.stage4.boss"

StageData {
	title: "Stage 4: The Golden City"
	subtitle: "So shiny, I want to pillage and stuff."
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	

	bosses: {midboss4, boss4}

	drawTitle: =>
		{:title, :subtitle} = @currentStage

		if @frame <= 30
			c = 255 * (@frame - 30) / 30
			love.graphics.setColor 200, 200, 200, c
		elseif @frame >= 150
			c = 255 - 255 * (@frame - 150) / 30
			love.graphics.setColor 200, 200, 200, c
		else
			love.graphics.setColor 200, 200, 200

		love.graphics.setFont titleFont

		w = titleFont\getWidth title
		h = titleFont\getHeight title

		love.graphics.print title,
			(@width - w) / 2,
			(@height - h) / 2

		love.graphics.setFont subtitleFont

		w2 = subtitleFont\getWidth subtitle

		love.graphics.print subtitle,
			(@width - w2) / 2,
			(@height + h) / 2

	drawBackground: =>
			-- No background for now.

	drawBossData: =>
		with x, y = @boss.x, @boss.y
			f = @boss.frame - @bossSince
			fm = math.min 1, f / 60 -- frame modifier, for starting animations.

			radius = 20 + (80 - 20) * fm
			width = 7

			alpha = 191 * fm

			love.graphics.setColor 255, 255, 255, alpha
			love.graphics.setLineWidth width
			love.graphics.arc "line", "open", x, y, radius,
				-math.pi/2, -math.pi/2 - math.pi * 2 * (@boss.health / @boss.maxHealth) * fm
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

	update: Wave.toUpdate {
		Wave {
			start: 60
			interval: 30
			count: 10
			(n) =>
				x = 0 + @width / 10 * (n - 0.5)
				y = 30

				@\addEntity Bullet SmallBullet
					:x, :y
					y: 0
					spawnTime: 40
					speed: 7
					color: {255, 0, 0}

					update: =>
						if @frame == 0
							@angle = @\angleToPlayer!
		}
		Wave {
			start: 0
			interval: 20
			count: 9
			(n) =>
				for i = -1, 1, 2
					@\addEntity items.power
						x: @width / 2 + 25 * i * n
						y: @height / 9 - 50

					@\addEntity items.lifeFragment
						x: @width / 2 + 25 * i * n
						y: @height / 9 - 10

					@\addEntity items.bombFragment
						x: @width / 2 + 25 * i * n
						y: @height / 9 + 30

					@\addEntity items.point
						x: @width / 2 + 25 * i * n
						y: @height / 90
		}
		Wave {
			name: "Boss wave"
			start: 180
			=>
				@\addEntity Boss boss4
		}
	}
}