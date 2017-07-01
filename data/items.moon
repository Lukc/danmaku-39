
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

		draw = =>
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - 16, @y - 16
		collection = (player) =>
			unless player\addPower 1
				player.score += 100
				@game.score += 100

		(arg) -> Item with {
				important: true
				radius: 10
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
	lifeFragment: do
		sprite = love.graphics.newImage "data/art/item_test_life.png"
		draw = =>
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - 32, @y - 32
		collection = (player) =>
			player\addFragment "life"

		(arg) -> Item with {
				important: true
				radius: 18
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
	bombFragment: do
		sprite = love.graphics.newImage "data/art/item_test_bomb.png"
		draw = =>
			love.graphics.setColor 255, 255, 255
			love.graphics.draw sprite, @x - 32, @y - 32
		collection = (player) =>
			player\addFragment "bomb"

		(arg) -> Item with {
				important: true
				radius: 10
				:draw
				:collection
			}
				for k,v in pairs arg
					[k] = v
}

