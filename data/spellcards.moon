
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

	direction  = bulletData.angle or math.pi / 2
	angle      = bulletData.direction or bulletData.angle or math.pi / 2

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
			.direction = direction

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

	returned = false

	->
		unless returned
			returned = true

			with clone bulletData
				.update = =>
					if oldUpdate
						oldUpdate self

					if reversed
						@direction = angle - math.cos @frame / 10
					else
						@direction = angle + math.cos @frame / 10

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

