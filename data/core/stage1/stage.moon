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

midboss1 = require "data.core.stage1.midboss"
boss1 = require "data.core.stage1.boss"

{:titleFont, :subtitleFont, :drawBossData} = require "data.core.common"

StageData {
	title: "Stage 1: Defend the colony!"
	subtitle: "Fires roar and bullets fly."
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	bosses: {midboss1, boss1}

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

	:drawBossData

	update: Wave.toUpdate {
		--Wave {
		--	start: 60
		--	interval: 30
		--	count: 10
		--	(n) =>
		--		x = 0 + @width / 10 * (n - 0.5)
		--		y = 30
		--
		--		@\addEntity Bullet SmallBullet
		--			:x, :y
		--			y: 0
		--			spawnTime: 40
		--			speed: 7
		--			color: {255, 0, 0}
		--
		--			update: =>
		--				if @frame == 0
		--					@angle = @\angleToPlayer!
		--}
		Wave {
			start: 0
			interval: 20
			count: 9
			(n) =>
				for i = -1, 1, 2
					@\addEntity 
						x: @width / 2 + 25 * i * n
						y: @height / 9 - 50
		}

		Wave {
			start: 20
			name: "MidBoss wave"
			=>
				@\addEntity Boss midboss1
		}

		Wave {
			start: 60 * 60 * 15
			name: "Boss wave"
			=>
				@\addEntity Boss boss1
		}
	}
}
