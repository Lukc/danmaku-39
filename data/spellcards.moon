
{
	:Entity,
	:Spellcard
} = require "danmaku"

{:BigBullet, :SmallBullet, :MiniBullet} = require "data.bullets"

{:radial, :circle, :sinusoid} = require "data.helpers"

s1 = Spellcard {
	health: 60
	timeout: 60 * 60
	update: =>
		if @frame % 6 == 0
			directionCoeur1 = math.pow(@frame, 2)*(math.pow(@x, 2) + math.pow(@y, 2))
			directionCoeur2 = math.pow((math.pow(@x, 2)+math.pow(@y, 2) - @frame * @x),2)

			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire BigBullet with bullet
					.color = {204, 0, 0}
					.speed = 4
					.direction = directionCoeur1
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire BigBullet with bullet
					.color = {0, 255, 0}
					.speed = 4
					.direction = directionCoeur2
}
s2 = Spellcard {
	health: 60
	timeout: 60 * 60
	update: =>
		if @frame % 5 == 0
			bullet =
				speed: 4
				direction:  @frame / 2 * math.pi / 8
				color: { 0,255,127 }
			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire BigBullet bullet
		if @frame % 3 == 0
			bullet =
				speed: 2
				direction:  @frame / 2 * math.pi / 10
			for bullet in radial {from: self, bullets: 10, :bullet}
				@\fire SmallBullet bullet
}

s3 = Spellcard {
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
s4 = Spellcard {
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
	s1, s2, s3, s4
}

