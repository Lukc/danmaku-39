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
spellcards = require "data.core.stage1.spellcards"
items = require "data.items"
characters = require "data.characters"

{:circle, :laser} = require "data.helpers"

{:StageData, :ModData, :BossData} = require "data.checks"

{:endOfSpell} = require "data.core.common"

BossData {
	radius: 40
	x: 600 / 2
	y: 800 / 5
	name: "Xuhe"
	title: "Familiar of Wisdom"
	description: "Wise Familiar"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	:endOfSpell

	--spellcards[1]
	spellcards[2]
	spellcards[3]
	spellcards[4]
}
