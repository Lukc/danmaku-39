spellcards = require "data.core.stage3.spellcards"
{:BossData} = require "data.checks"
{:endOfSpell} = require "data.core.common"
{:Difficulties} = require "danmaku.danmaku"

BossData {
	radius: 32
	x: 600 / 2
	y: 800 / 5
	name: "Urquchillay"
	title: "Fluffy and explosion"
	description: "Lovable but Deadly Goddess"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	:endOfSpell

	spellcards[6]
	spellcards[7]
	spellcards[8]
	spellcards[9]
	spellcards[10]
	spellcards[11]
}
