
{
	:Entity,
	:Spellcard
} = require "danmaku"

{:BigBullet, :SmallBullet, :MiniBullet} = require "data.bullets"

{:radial, :circle, :sinusoid} = require "data.helpers"

s1 = Spellcard {
	name: "Test Karakayn - Named Spellcards test"
	health: 140
	timeout: 60 * 60
	update: =>
		if @frame % 10 == 0
			bullet =
				speed: 8
				direction: math.sin((@frame - 60) / 180) * math.pi / 6 + @\angleToPlayer!
				color: { 255, 0, 127 }
			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire MiniBullet bullet
		if @frame % 12 == 0

			bullet =
				speed: 5
				direction: math.sqrt(math.cos(@x)) * math.cos(30/@x) - 1 + math.sqrt(math.abs(@x))
				color: { 255, 0, 127 }
			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire BigBullet bullet
				print "deuxieme type bullet"

}
s2 = Spellcard {
	health: 60
	timeout: 30 * 60
	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}
s3 = Spellcard {
	name: "Test sign - Named Spellcards test"
	health: 60
	timeout: 30 * 60
	update: =>
		if @frame % 10 == 0
			angle = math.pi / 2 + math.pi / 6 * @frame / 10

			for bullet in circle {from: self}
				@\fire with bullet
					.hitbox = Entity.Rectangle
					.w = 20
					.h = 10
					.color = {255, 127, 255}
					.speed = 2.5
					.direction = angle

		if @frame % 30 == 0
			for bullet in radial {from: self, bullets: 4}
				for bullet in sinusoid {from: self, :angle, :bullet}
					for bullet in circle {from: self, :angle, :bullet}
						@\fire SmallBullet with bullet
							.color = {255, 0, 0}
							.speed = 4

				for bullet in sinusoid {from: self, :angle, :bullet, reversed: true}
					for bullet in circle {from: self, :angle, :bullet}
						@\fire SmallBullet with bullet
							.color = {0, 255, 0}
							.speed = 4

}

{
	s1, s2, s3
}

