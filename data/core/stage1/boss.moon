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

Wave = require "data.wave"
{:StageData, :ModData, :BossData} = require "data.checks"

{:circularDrop} = require "data.core.common"

BossData {
	radius: 40
	x: 600 / 2
	y: 800 / 5
	direction: nil
	speed: 0
	name: "Coactlicue"
	title: "War Shaman"
	description: "Shaman of War and stuff.\nShe has a godly lance that spits fire. Beware its deadly burns."
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	-- Fonction de mouvement pour Boss : bouge régulièrement sur la gauche et la droite
	--moveLR: =>
	--	if @x <= 600
	--		speed = 3
	--		direction = -math.pi
	--	else
	--		speed = 3
	--		direction = 0

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

	spellcards[5]
	spellcards[6]
	spellcards[7]
	spellcards[8]
	spellcards[9]
	spellcards[10]
}

