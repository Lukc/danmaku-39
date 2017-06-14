
{
	:Entity,
	:Spellcard
} = require "danmaku"

{:BigBullet, :SmallBullet} = require "data.bullets"

fireCircle = (arg) ->
	arg or= {}

	entity = arg.from
	angle = arg.angle or math.pi / 2
	radius = arg.radius or entity.radius or math.max(entity.width, entity.height)
	bulletData = arg.bullet or {}
	bulletsPerCircle = arg.bullets or 6

	unless entity
		print "usage: fireCircle {from: Entity, bullet: {...}, ...}"
		return

	for i = 1, bulletsPerCircle
		a = angle + math.pi * 2 / bulletsPerCircle * i
		x, y = entity.x, entity.y

		x = x + radius * math.cos a
		y = y + radius * math.sin a

		bulletData.x = x
		bulletData.y = y
		bulletData.angle = a

		entity\fire bulletData

fireSinusoid = (arg) ->
	arg or= {}

	entity = arg.from
	bulletData = arg.bullet or {}

	angle = arg.angle or math.pi / 2
	inverted = arg.inverted or false

	oldUpdate = bulletData.update
	bulletData.update = =>
		if oldUpdate
			oldUpdate self

		if inverted
			@direction = angle - math.cos @frame / 10
		else
			@direction = angle + math.cos @frame / 10

	entity\fire bulletData

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

			fireCircle
				from: self
				bullet:
					hitbox: Entity.Rectangle
					w: 20
					h: 10
					color: {255, 127, 255}
					speed: 2.4
					direction: angle
				:angle

		if @frame % 10 == 0
			for i = 1, 4
				angle = math.pi / 2 * i

				fireSinusoid
					from: self
					bullet: SmallBullet
						color: {127, 127, 0}
						speed: 4
					:angle

				fireSinusoid
					from: self
					bullet: SmallBullet
						color: {127, 255, 0}
						speed: 4
					inverted: true
					:angle

}

{
	s1, s2
}

