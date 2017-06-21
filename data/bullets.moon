
newBullet = (arg) ->
	arg or= {}

	sprite = arg.sprite
	color = arg.color or {255, 255, 255, 255}

	arg.speed or= 2.5

	oldDraw = arg.draw

	arg.draw = =>
		-- Setting custom properties, duh~
		unless @color
			@color = color
		unless @sprite
			@sprite = sprite

		x = @x - sprite\getWidth! / 2
		y = @y - sprite\getWidth! / 2

		if @dying
			color[4] = 255 - 255 * (@dyingFrame / @dyingTime)
		elseif @frame <= 30
			color[4] = 255 * @frame / 30
		love.graphics.setColor @color
		love.graphics.draw @sprite,
			x, y

		if oldDraw
			oldDraw self

	arg

BigBullet = do
	sprite = love.graphics.newImage "data/art/bullet_test.png"

	(arg) ->
		arg or= {}

		unless arg.sprite
			arg.sprite = sprite
		unless arg.radius
			arg.radius = 21

		newBullet arg

SmallBullet = do
	sprite = love.graphics.newImage "data/art/bullet_test2.png"

	(arg) ->
		arg or= {}

		unless arg.sprite
			arg.sprite = sprite
		unless arg.radius
			arg.radius = 5

		newBullet arg

MiniBullet = do
	sprite = love.graphics.newImage "data/art/bullet_test3.png"

	(arg) ->
		arg or= {}

		unless arg.sprite
			arg.sprite = sprite
		unless arg.radius
			arg.radius = 3

		newBullet arg

--------------------------------------
-- FIXME: SPRITELESS BULLETS FOLLOW --
--------------------------------------

HugeBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 26

		arg

ArrowHead = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 7

		arg

BurningBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 12

		arg

{
	:HugeBullet
	:BigBullet
	:SmallBullet
	:MiniBullet

	:ArrowHead
	:BurningBullet
}

