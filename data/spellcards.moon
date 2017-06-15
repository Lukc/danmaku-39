
{
	:Entity,
	:Spellcard
} = require "danmaku"

{:BigBullet, :SmallBullet} = require "data.bullets"

clone = (t) ->
	{key, value for key, value in pairs t}

radial = (arg) ->
	arg or= {}

	entity     = arg.from
	radius     = arg.radius or entity.radius or math.max(entity.width, entity.height)
	bulletData = arg.bullet or {}
	bulletsPerCircle = arg.bullets or 6

	unless entity
		return ->

	angle     = bulletData.angle or math.pi / 2
	direction = bulletData.direction or bulletData.angle or math.pi / 2

	i = 0
	->
		i += 1

		if i > bulletsPerCircle
			return

		a = direction + math.pi * 2 / bulletsPerCircle * i
		x, y = entity.x, entity.y

		x = x + radius * math.cos a
		y = y + radius * math.sin a

		with clone bulletData
			.x = x
			.y = y
			.angle = a
			.direction = a

circle = (arg) ->
	arg or= {}

	entity     = arg.from
	angle      = arg.angle or math.pi / 2
	radius     = arg.radius or entity.radius or math.max(entity.width, entity.height)
	bulletData = arg.bullet or {}
	bulletsPerCircle = arg.bullets or 6

	if bulletData.angle
		angle += bulletData.angle

	unless entity
		return ->

	i = 0
	->
		i += 1

		if i > bulletsPerCircle
			return

		a = angle + math.pi * 2 / bulletsPerCircle * i
		x, y = entity.x, entity.y

		x = x + radius * math.cos a
		y = y + radius * math.sin a

		with clone bulletData
			.x = x
			.y = y
			.angle = a
			.direction = angle

sinusoid = (arg) ->
	arg or= {}

	entity     = arg.from
	bulletData = arg.bullet or {}
	angle      = arg.angle or math.pi / 2
	reversed   = arg.reversed or false

	oldUpdate  = bulletData.oldUpdate

	if bulletData.angle
		angle += bulletData.angle

	unless entity
		return ->

	a, b = arg[1], arg[2]

	unless a
		a = 1
	unless b
		b = 10

	returned = false

	->
		unless returned
			returned = true

			with clone bulletData
				.update = =>
					if oldUpdate
						oldUpdate self

					if reversed
						@direction = angle - a * math.cos @frame / b
					else
						@direction = angle + a * math.cos @frame / b

s1 = Spellcard {
	health: 40
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
s2 = Spellcard {
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
	s1, s2
}

