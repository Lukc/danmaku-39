
{
	:Spellcard
} = require "danmaku"

{:BigBullet, :SmallBullet} = require "data.bullets"

s1 = Spellcard {
	health: 40
	timeout: 30 * 60
	update: =>
		if @frame % 40 == 0
			for i = 1, 32
				@\fire BigBullet
					speed: 2.4
					angle: math.pi / 16 * i + (@frame / 60 * math.pi / 32)

		if @frame % 12 == 0
			for i = 1, 8
				@\fire SmallBullet
					speed: 3.6
					-- The “60” here is the start of the attacks.
					angle: math.pi / 4 * (i - 0.5) + math.sin (@frame - 60) / 90 * math.pi / 6
					color: {
						192 + 63 * math.sin(@frame / 60 + math.pi),
						96 + 31 * math.sin @frame / 60,
						192 + 63 * math.sin(@frame / 60),
					}
}
s2 = Spellcard {
	name: "Test sign - Named Spellcards test"
	health: 60
	timeout: 30 * 60
	update: =>
		if @frame % 10 == 0
			@\fire SmallBullet
				speed: 2.4
				color: {255, 127, 255}
}

{
	s1, s2
}

