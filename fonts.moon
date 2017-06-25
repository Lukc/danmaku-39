
cache = {}

{
	get: (name, size) ->
		unless cache[name]
			cache[name] = {}

		unless cache[name][size]
			filePath = "data/fonts/" .. name.. ".otf", size

			cache[name][size] = love.graphics.newFont filePath, size

		return cache[name][size]
}

