
images = require "images"

newBullet = (arg) ->
	arg or= {}

	backgroundSprite = arg.backgroundSprite
	overlaySprite = arg.overlaySprite
	defaultRadius = arg.defaultRadius or 1

	color = arg.color or {127, 127, 127, 255}

	arg.speed or= 2.5

	oldDraw = arg.draw

	arg.draw = =>
		-- FIXME: Sprites should be builtin. We may need them for
		--        spritebatches in the future.
		unless @color
			@color = color

		unless @backgroundSprite
			@backgroundSprite = backgroundSprite
		unless @overlaySprite
			@overlaySprite = overlaySprite

		sprite = @backgroundSprite or @overlaySprite

		unless sprite
			return

		sw, sh = sprite\getWidth!, sprite\getHeight!

		currentColor = [c for c in *@color]
		currentColor[4] or= 255

		if @dying
			currentColor[4] = math.min(currentColor[4], 255 - 255 * (@dyingFrame / @dyingTime))
		if @frame <= 20
			currentColor[4] = math.min(currentColor[4], 255 * @frame / 20)

		sizeRatio = @radius / defaultRadius

		if @backgroundSprite
			love.graphics.setColor 255, 255, 255, currentColor[4]
			love.graphics.draw @backgroundSprite,
				@x, @y, @angle + math.pi/2, sizeRatio, sizeRatio, sw/2, sh/2

		if @overlaySprite
			love.graphics.setColor currentColor
			love.graphics.draw @overlaySprite,
				@x, @y, @angle + math.pi/2, sizeRatio, sizeRatio, sw/2, sh/2

		if oldDraw
			oldDraw self

	arg

BigBullet = do
	-- FIXME: Cache those.
	bg = images.get "bullet_1_bg.png"
	overlay = images.get "bullet_2_overlay.png"

	(arg) ->
		arg or= {}

		arg.backgroundSprite or= bg
		arg.overlaySprite    or= overlay

		arg.defaultRadius or= 64
		arg.radius        or= 21

		newBullet arg

SmallBullet = do
	bg = images.get "bullet_1_bg.png"
	overlay = images.get "bullet_1_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 64
		arg.radius        or= 7

		newBullet arg

MiniBullet = do
	bg = images.get "bullet_1_bg.png"
	overlay = images.get "bullet_1_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 64
		arg.radius        or= 3

		newBullet arg

SimpleBullet = do
	bg = images.get "bullet_1_bg.png"
	overlay = images.get "bullet_1_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 64
		arg.radius        or= 12

		newBullet arg

HugeBullet = do
	overlay = images.get "bullet_1_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay

		arg.defaultRadius or= 64
		arg.radius        or= 26

		newBullet arg

StarBullet = do
	bg = images.get "bullet_star_bg.png"
	overlay = images.get "bullet_star_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 48
		arg.radius        or= 12

		newBullet arg

BigStarBullet = do
	bg = images.get "bullet_star_bg.png"
	overlay = images.get "bullet_star_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 48
		arg.radius        or= 21

		newBullet arg

SquareBullet = do
	bg = images.get "bullet_square_bg.png"
	overlay = images.get "bullet_square_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 48
		arg.radius        or= 21

		newBullet arg

--------------------------------------
-- FIXME: SPRITELESS BULLETS FOLLOW --
--------------------------------------

ArrowHead = do
	overlay = images.get "bullet_arrowhead.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite or= overlay

		arg.defaultRadius or= 7
		arg.radius or= 7

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

SpecialStrangeBullet = do
	sprite = images.get "special_strange_bullet.png"

	(arg) ->
		arg or= {}

		unless arg.sprite
			arg.sprite = sprite
		unless arg.radius
			arg.radius = 5

		newBullet arg
{
	:HugeBullet
	:BigBullet
	:SimpleBullet
	:SmallBullet
	:MiniBullet

	:ArrowHead
	:Diamond
	:SquareBullet

	:BurningBullet

	:DarkBullet
	:MiniDarkBullet

	:StarBullet
	:BigStarBullet

	:SpecialStrangeBullet
}

