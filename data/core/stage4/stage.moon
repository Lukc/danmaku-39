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

{:StageData, :ModData, :BossData} = require "data.checks"

fonts = require "fonts"

midboss4 = require "data.core.stage4.midboss"
boss4 = require "data.core.stage4.boss"

{:titleFont, :subtitleFont, :drawBossData} = require "data.core.common"

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

	:drawBossData
}
