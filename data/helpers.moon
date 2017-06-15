
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

{
	:clone,
	:radial,
	:circle,
	:sinusoid
}

