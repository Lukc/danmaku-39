
Entity = require "danmaku.entity"

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
	overlay = images.get "bullet_3_overlay.png"

	(arg) ->
		arg or= {}

		arg.backgroundSprite or= bg
		arg.overlaySprite    or= overlay

		arg.defaultRadius or= 72
		arg.radius        or= 21

		newBullet arg

SmallBullet = do
	bg = images.get "bullet_1_bg.png"
	overlay = images.get "bullet_2_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 72
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

		arg.defaultRadius or= 72
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

DiamondBullet = do
	bg = images.get "bullet_diamond_bg.png"
	overlay = images.get "bullet_diamond_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 26
		arg.radius        or= 8

		newBullet arg

OvalBullet = do
	bg = images.get "bullet_oval_bg.png"
	overlay = images.get "bullet_oval_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 47
		arg.radius        or= 8

		newBullet arg

HeartBullet = do
	bg = images.get "bullet_heart_bg.png"
	overlay = images.get "bullet_heart_overlay.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite    or= overlay
		arg.backgroundSprite or= bg

		arg.defaultRadius or= 49
		arg.radius        or= 8

		newBullet arg

DarkBullet = do
	backgroundSprite = images.get "bullet_dark_bg.png"
	overlaySprite = images.get "bullet_dark_overlay.png"

	(arg) ->
		arg or= {}

		arg.backgroundSprite or= backgroundSprite
		arg.overlaySprite or= overlaySprite
		arg.defaultRadius or= 55
		arg.radius or= 12

		newBullet arg

MiniDarkBullet = do
	(arg) ->
		arg or= {}

		arg.radius or= 3

		DarkBullet arg

ArrowHeadBullet = do
	backgroundSprite = images.get "bullet_arrowhead_bg.png"
	overlaySprite = images.get "bullet_arrowhead_overlay.png"

	(arg) ->
		arg or= {}

		arg.backgroundSprite or= backgroundSprite
		arg.overlaySprite or= overlaySprite
		arg.defaultRadius or= 7 -- Very big sprite, very small hitbox.
		arg.radius or= 2.5

		newBullet arg

--------------------------------------
-- FIXME: SPRITELESS BULLETS FOLLOW --
--------------------------------------

BurningBullet = do
	(arg) ->
		arg or= {}

		unless arg.radius
			arg.radius = 12

		arg

---
-- Bullety and yet non-bullet follow.
---

Curvy = do
	-- Curvy lasers.
	-- Have to be fired in very close succession to be of any use.
	-- DO NOT ABUSE THEM.
	sprite = images.get "bullet_curvy.png"

	(arg) ->
		arg or= {}

		arg.overlaySprite or= sprite
		arg.defaultRadius or= 24
		arg.radius or= 12

		newBullet arg

Cloud = do
	-- Actively hostile particles. Will cloud your screen and make you cry.
	-- Not very costly, but don’t put them everywhere. They make people
	-- cry for real.
	sprite = images.get "cloud_1.png"
	(arg) ->
		arg or= {}

		color = arg.color or {0, 0, 0}
		radius = arg.radius or 128

		Entity with arg
			.touchable or= false -- Should not matter, will be a particle.
			.speed or= 1.5
			.outOfScreenTime or= 90 -- Large sprite. Will need it.
			.radius or= radius
			.draw or= =>
				sw, sh = sprite\getWidth!, sprite\getHeight!

				alpha = math.min 255, 255 * @frame / 20

				love.graphics.setColor color[1], color[2], color[3], alpha
				love.graphics.draw sprite,
					@x, @y, nil,
					@radius / sw * 2, radius / sh * 2,
					sw/2, sh/2

{
	:newBullet

	:HugeBullet
	:BigBullet
	:SimpleBullet
	:SmallBullet
	:MiniBullet

	:ArrowHeadBullet
	:OvalBullet
	:DiamondBullet
	:SquareBullet

	:BurningBullet

	:DarkBullet
	:MiniDarkBullet

	:StarBullet
	:BigStarBullet

	:HeartBullet

	:SpecialStrangeBullet

	:Curvy

	:Cloud
}

