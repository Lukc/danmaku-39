
cache = {
	__default: {}
}

{
	get: (name, size) ->
		unless name
			cache.__default[size] or= love.graphics.newFont size

			return cache.__default[size]

		unless cache[name]
			cache[name] = {}

		unless cache[name][size]
			filePath = "data/fonts/" .. name.. ".otf", size

			cache[name][size] = love.graphics.newFont filePath, size

		return cache[name][size]
}

