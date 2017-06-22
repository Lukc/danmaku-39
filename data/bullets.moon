
newBullet = (arg) ->
	arg or= {}

	sprite = arg.sprite
	color = arg.color or {255, 255, 255, 255}

	arg.speed or= 2.5

	oldDraw = arg.draw

	arg.draw = =>
		-- FIXME: Setting custom properties, duh~
		unless @color
			@color = color
		unless @sprite
			@sprite = sprite

		sw, sh = sprite\getWidth!, sprite\getHeight!

		currentColor = [c for c in *@color]
		currentColor[4] or= 255

		if @dying
			currentColor[4] = math.min(currentColor[4], 255 - 255 * (@dyingFrame / @dyingTime))
		if @frame <= 20
			currentColor[4] = math.min(currentColor[4], 255 * @frame / 20)

		love.graphics.setColor currentColor
		love.graphics.draw @sprite,
			@x, @y, @angle, nil, nil, sw/2, sh/2

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

SimpleBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 12

		arg

HugeBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 26

		arg

ArrowHead = do
	sprite = love.graphics.newImage "data/art/bullet_arrowhead.png"

	(arg) ->
		arg or= {}

		unless arg.sprite
			arg.sprite = sprite

		unless arg.radius
			arg.radius = 7

		newBullet arg

BurningBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 12

		arg

Diamond = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 8

		arg

DarkBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 12

		arg

MiniDarkBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 3

		arg

StarBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 12

		arg

BigStarBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 21

		arg

{
	:HugeBullet
	:BigBullet
	:SimpleBullet
	:SmallBullet
	:MiniBullet

	:ArrowHead
	:Diamond

	:BurningBullet

	:DarkBullet
	:MiniDarkBullet

	:StarBullet
	:BigStarBullet
}

