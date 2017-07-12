 
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

stage1 = require "data.core.stage1.stage"
stage2 = require "data.core.stage2.stage"
stage3 = require "data.core.stage3.stage"
stage4 = require "data.core.stage4.stage"
stage5 = require "data.core.stage5.stage"
stage6 = require "data.core.stage6.stage"
stage7 = require "data.core.stage7.stage"

ModData {
	name: "Core Data"
	stages: {
		stage1
		stage2
		stage3
		stage4
		stage5
		stage6
		stage7
	}
	stories: {
		{
			name: "Mystical Lands of Sunset"
			stages: {
				stage1
				stage2
				stage3
				stage4
				stage5
				stage6
				stage7
			}
		}
	}
	spellcards: spellcards
	:characters
	characterVariants: characters.variants
}

