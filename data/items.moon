
images = require "images"

{:Item} = require "danmaku"

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

		(arg) -> Item with {
				radius: 10
				:draw
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

		(arg) -> Item with {
				marker: "bomb"
				radius: 18
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
}

