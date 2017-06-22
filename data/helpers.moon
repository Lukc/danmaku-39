
{:Entity} = require "danmaku"

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

column = (arg) ->
	-- FIXME: Alternatively use bullet.speed as startSpeed..
	arg or= {}

	bullets    = arg.bullets or 3
	startSpeed = arg.startSpeed or 2
	endSpeed   = arg.endSpeed   or 3

	bulletData = arg.bullet or {}

	i = 0

	->
		i += 1

		if i >= bullets
			return

		with clone bulletData
			.speed = startSpeed + (endSpeed - startSpeed) * (i - 1) / bullets

row = (arg) ->
	arg or= {}

	bullets    = arg.bullets or 3
	startAngle = arg.startAngle or -math.pi / 8
	endAngle   = arg.endAngle   or  math.pi / 8

	bulletData = arg.bullet or {}

	i = 0

	->
		i += 1

		if i >= bullets
			return

		with clone bulletData
			.angle = (.angle or math.pi/2) + startAngle + (endAngle - startAngle) * (i - 1) / bullets

attachedLaser = do
	update = (parent, duration, oldUpdate) ->
		=>
			if parent.readyForRemoval
				@\die!

				print "WARNING: Laser's parent died."

				-- This sounds terribly bad.
				return

			if oldUpdate
				oldUpdate self

			radius = parent.radius

			radius += @height / 2

			@x = parent.x + radius * math.cos @angle
			@y = parent.y + radius * math.sin @angle

			if @frame - 1 >= duration
				@\die!

	(arg) ->
		arg or= {}

		entity     = arg.from
		bulletData = arg.bullet or {}
		duration   = arg.duration or math.huge

		angle      = bulletData.angle or math.pi / 2
		w          = bulletData.w or 5
		h          = bulletData.h or 25
		oldUpdate  = bulletData.update

		radius     = entity.radius or 10

		damageable = if bulletData.damageable != nil
			bulletData.damageable
		else
			false

		unless entity
			return nil

		with clone bulletData
			.update = update(entity, duration, oldUpdate)
			.hitbox = Entity.Rectangle
			.damageable = damageable

laser = do
	(arg) ->
		arg or= {}

		entity = arg.from
		bulletData = arg.bullet or {}

		angle = bulletData.angle or math.pi / 2
		w     = bulletData.w or 5
		h     = bulletData.h or 25

		origin =
			x: entity.x
			y: entity.y

		speed = bulletData.speed or 3

		oldUpdate = bulletData.update

		damageable = if bulletData.damageable != nil
			bulletData.damageable
		else
			false

		with clone bulletData
			.hitbox = Entity.Rectangle
			.speed = 0
			.damageable = damageable
			.h = 0
			.update = =>
				if @height != h
					@x = origin.x +
						speed * @frame * math.cos angle
					@y = origin.y +
						speed * @frame * math.sin angle

					@height = math.min h, speed * @frame * 2

					if @height == h
						@speed = speed

				if oldUpdate
					oldUpdate self

{
	:clone
	:radial
	:circle
	:sinusoid

	:column
	:row

	-- Move to data.bullets?
	:laser
	:attachedLaser
}

