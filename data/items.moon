
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
			alpha = math.min 255, 255 * @frame / 60

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

		love.graphics.setColor color
		love.graphics.draw innerCircle, @x, @y,
			nil,
			nil, nil,
			innerCircle\getWidth!/2, innerCircle\getHeight!/2

		love.graphics.setColor [c + 32 for c in *color]
		love.graphics.draw circle, @x, @y,
			nil,
			nil, nil,
			circle\getWidth!/2, circle\getHeight!/2

		love.graphics.setColor color
		love.graphics.draw circle, @x, @y,
			math.cos(@frame/60),
			wmod, hmod,
			circle\getWidth!/2, circle\getHeight!/2

{
	point: do
		sprite = love.graphics.newImage "data/art/item_test_point.png"

		draw = =>
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - 16, @y - 16
		collection = (player) =>
			player.score += 1000
			@game.score += 1000

			player.customData.points or= 0
			player.customData.points += 1

			@game\addEntity TextParticle "1000", player.x, player.y

		(arg) -> Item with {
				radius: 10
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
			love.graphics.setColor 255, 255, 255, 127
			love.graphics.draw sprite, @x - 16, @y - 16
		collection = (player) =>
			player.score += 50
			@game.score += 50

			player.customData.points or= 0
			player.customData.points += 1

			@game\addEntity TextParticle "50", player.x, player.y

		(arg) -> Item with {
				radius: 7
				speed: 12
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
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - w2, @y - h2

			drawCircle self, {255, 127, 127}
		collection = (player) =>
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
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - w2, @y - h2

			drawCircle self, {255, 127, 191}
		collection = (player) =>
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
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - w2, @y - h2

			drawCircle self, {127, 255, 191}
		collection = (player) =>
			player\addFragment "bomb"

			@game\addEntity TextParticle "life shard", player.x, player.y, {
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

