
{:Item} = require "danmaku"

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
		sprite = love.graphics.newImage "data/art/item_test_life.png"
		w2 = sprite\getWidth!/2
		h2 = sprite\getWidth!/2

		draw = =>
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - w2, @y - h2
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

