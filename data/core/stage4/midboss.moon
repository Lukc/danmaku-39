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
spellcards = require "data.core.stage4.spellcards"
items = require "data.items"
characters = require "data.characters"

{:circle, :laser} = require "data.helpers"

Wave = require "data.wave"
{:StageData, :ModData, :BossData} = require "data.checks"

{:circularDrop} = require "data.core.common"

BossData {
	radius: 32
	x: 600 / 2
	y: 800 / 5
	name: "Zipacna (1)"
	description: "First time around for the crocodile"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	endOfSpell: (spell) =>
		local pointItems, powerItems

		if @spellSuccess
			@game\addEntity items.lifeFragment
				x: @x
				y: @y
			pointItems = 12
			powerItems = 8
		else
			@game\addEntity items.bombFragment
				x: @x
				y: @y
			pointItems = 8
			powerItems = 6

		circularDrop self, pointItems, 48, items.point
		circularDrop self, powerItems, 30, items.power

	spellcards[1]
	spellcards[2]
	spellcards[3]
}
