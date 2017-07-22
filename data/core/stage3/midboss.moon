spellcards = require "data.core.stage3.spellcards"
{:BossData} = require "data.checks"
{:endOfSpell} = require "data.core.common"

BossData {
	radius: 32
	x: 600 / 2
	y: 800 / 5
	name: "The Lamhydra"
	description: "River Monster"

	:endOfSpell

	spellcards[1]
	spellcards[2]
	spellcards[3]
	spellcards[4]
	spellcards[5]
}