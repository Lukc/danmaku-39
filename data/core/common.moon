
{
	titleFont: love.graphics.newFont 42
	subtitleFont: love.graphics.newFont 24

	circularDrop: (entity, count, radius, constructor) ->
		for i = 1, count
			a = math.pi * 2 / count * i

			x = entity.x + radius * math.cos a
			y = entity.y + radius * math.sin a

			entity.game\addEntity constructor
				:x, :y
}

