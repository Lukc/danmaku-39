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

{:StageData, :WaveData} = require "data.checks"

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

	waves: {
		WaveData {
			timeout: 300
			update: (game) =>
				print "update:", self, game
				if @frame % 60 != 0
					return
				n = @frame / 60

				for i = -1, 1, 2
					game\addEntity items.point
						x: game.width / 2 + 25 * i * n
						y: game.height / 9 - 50
		}

		WaveData {
			name: "MidBoss wave"
			finished: =>
				@frame > 60 * 5 and not @game.boss
			update: (game) =>
				if @frame == 1
					game\addEntity Boss midboss1
		}

		WaveData {
			name: "Boss wave"
			finished: =>
				@frame > 60 * 5 and not @game.boss
			update: (game) =>
				if @frame == 1
					game\addEntity Boss boss1
		}
	}
}
