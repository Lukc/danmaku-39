
images = require "images"
fonts = require "fonts"

{:Item, :Entity} = require "danmaku"

TextParticle = (text, x, y, opt) ->
	opt or= {}

	Entity {
		:x, :y
		spawnTime: 20
		dyingTime: 20
		update: =>
			@y -= 1

			if not @dying and @frame == @spawnTime + 20
				@\die!
		draw: =>
			alpha = math.min 255, 255 * @frame / @spawnTime

			if @dying
				alpha = math.min alpha, 255 - 255 * @dyingFrame / @dyingTime

			color = if opt.color
				[c for c in *opt.color]
			else
				{200, 200, 200}
			color[4] = alpha

			font = fonts.get "Sniglet-Regular", opt.size or 15

			love.graphics.setColor color
			love.graphics.setFont font
			love.graphics.print text,
				@x - font\getWidth(text) / 2, @y - font\getHeight!/2
	}

drawCircle = do
	circle = images.get "item_circle.png"
	innerCircle = images.get "item_circle_inner.png"

	(color) =>
		wmod = math.cos @frame/60
		hmod = 1

		color = [c for c in *color]
		color[4] or= 255

		alphaModifier = 1
		sizeModifier = 1

		if @dying
			alphaModifier = 1 - @dyingFrame / @dyingTime
			sizeModifier = 1 + @dyingFrame / @dyingTime

			color[4] *= alphaModifier

		love.graphics.setColor color
		love.graphics.draw innerCircle, @x, @y,
			nil,
			sizeModifier, sizeModifier,
			innerCircle\getWidth!/2, innerCircle\getHeight!/2

		love.graphics.setColor [c + 32 for c in *color]
		love.graphics.draw circle, @x, @y,
			nil,
			sizeModifier, sizeModifier,
			circle\getWidth!/2, circle\getHeight!/2

		love.graphics.setColor color
		love.graphics.draw circle, @x, @y,
			math.cos(@frame/60),
			wmod * sizeModifier, hmod * sizeModifier,
			circle\getWidth!/2, circle\getHeight!/2

drawMarker = do
	marker = images.get "marker_small.png"

	(color) =>
		alpha = color[4] or 255
		if @dying
			alpha *= 1 - @dyingFrame / @dyingTime

		love.graphics.setColor color[1], color[2], color[3], alpha
		love.graphics.draw marker,
			@x, @game.height, nil, nil, nil,
			marker\getWidth!/2, marker\getHeight!

{
	point: do
		background = images.get "item_circle_inner.png"
		sprite = love.graphics.newImage "data/art/item_test_point.png"

		draw = =>
			alphaModifier = 1 - @dyingFrame / @dyingTime

			love.graphics.setColor 63, 127, 255, 223 * alphaModifier
			love.graphics.draw background, @x, @y, nil, 0.4, 0.4,
				background\getWidth! / 2, background\getHeight! / 2

			love.graphics.setColor 255, 255, 255, 255 * alphaModifier
			love.graphics.draw sprite, @x - 16, @y - 16

			drawMarker self, {63, 127, 255, 63}
		collection = (player) =>
			@speed = 0
			@direction = -math.pi / 2

			player.score += 1000
			@game.score += 1000

			player.customData.points or= 0
			player.customData.points += 1

			@game\addEntity TextParticle "1000", player.x, player.y

		(arg) -> Item with {
				radius: 10
				dyingTime: 10
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
	cancellationPoint: do
		sprite = love.graphics.newImage "data/art/item_cancellation_point.png"

		update = =>
			@direction = @\angleToPlayer!
		draw = =>
			alphaModifier = 1 - @dyingFrame / @dyingTime

			love.graphics.setColor 255, 255, 255, 127
			love.graphics.draw sprite, @x - 16, @y - 16
		collection = (player) =>
			@speed = 0
			@direction = -math.pi / 2

			player.score += 50
			@game.score += 50

			player.customData.points or= 0
			player.customData.points += 1

			@game\addEntity TextParticle "50", player.x, player.y

		(arg) -> Item with {
				radius: 7
				speed: 12
				dyingTime: 10
				:draw
				:update
				:collection
			}
				for k,v in pairs arg
					[k] = v
	power: do
		sprite = love.graphics.newImage "data/art/item_test_power.png"
		w2 = sprite\getWidth!/2
		h2 = sprite\getWidth!/2

		draw = =>
			alphaModifier = 1
			sizeModifier = 1

			if @dying
				alphaModifier = 1 - @dyingFrame / @dyingTime
				sizeModifier = 1 + @dyingFrame / @dyingTime

			love.graphics.setColor 255, 255, 255, 255 * alphaModifier
			love.graphics.draw sprite, @x, @y, nil,
				sizeModifier, sizeModifier,
				w2, h2

			drawCircle self, {255, 63, 63}

			drawMarker self, {255, 63, 63}
		collection = (player) =>
			@speed = 0
			@direction = -math.pi / 2

			unless player\addPower 1
				player.score += 100
				@game.score += 100

				@game\addEntity TextParticle "10000", player.x, player.y, {
					color: {255, 255, 127}
					size: 18
				}
			else
				@game\addEntity TextParticle "power shard", player.x, player.y, {
					color: {255, 127, 127}
					size: 23
				}

		(arg) -> Item with {
				marker: "power"
				radius: 18
				dyingTime: 60
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
	lifeFragment: do
		sprite = images.get "item_test_life.png"
		w2 = sprite\getWidth!/2
		h2 = sprite\getWidth!/2

		draw = =>
			alphaModifier = 1
			sizeModifier = 1

			if @dying
				alphaModifier = 1 - @dyingFrame / @dyingTime
				sizeModifier = 1 + @dyingFrame / @dyingTime

			love.graphics.setColor 255, 255, 255, 255 * alphaModifier
			love.graphics.draw sprite, @x, @y, nil,
				sizeModifier, sizeModifier,
				w2, h2

			drawCircle self, {255, 127, 191}
			drawMarker self, {255, 127, 191}
		collection = (player) =>
			@speed = 0
			@direction = -math.pi / 2

			player\addFragment "life"

			@game\addEntity TextParticle "life shard", player.x, player.y, {
				color: {255, 127, 191}
				size: 23
			}

		(arg) -> Item with {
				marker: "life"
				radius: 18
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
	bombFragment: do
		sprite = love.graphics.newImage "data/art/item_test_bomb.png"
		w2 = sprite\getWidth!/2
		h2 = sprite\getWidth!/2

		draw = =>
			alphaModifier = 1
			sizeModifier = 1

			if @dying
				alphaModifier = 1 - @dyingFrame / @dyingTime
				sizeModifier = 1 + @dyingFrame / @dyingTime

			love.graphics.setColor 255, 255, 255, 255 * alphaModifier
			love.graphics.draw sprite, @x, @y, nil,
				sizeModifier, sizeModifier,
				w2, h2

			drawCircle self, {127, 255, 191}
			drawMarker self, {127, 255, 191}
		collection = (player) =>
			@speed = 0
			@direction = -math.pi / 2

			player\addFragment "bomb"

			@game\addEntity TextParticle "spell shard", player.x, player.y, {
				color: {127, 255, 191}
				size: 23
			}

		(arg) -> Item with {
				marker: "bomb"
				radius: 18
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
}

