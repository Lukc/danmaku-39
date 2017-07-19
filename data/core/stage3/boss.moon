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
spellcards = require "data.core.stage3.spellcards"
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
	name: "Urquchillay"
	description: "Lovable but Deadly Goddess"
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

	spellcards[6]
	spellcards[7]
	spellcards[8]
	spellcards[9]
	spellcards[10]
}
