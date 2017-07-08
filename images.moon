
cache = {
	__default: {}
}

{
	get: (name) ->
		unless cache[name]
			cache[name] = love.graphics.newImage "data/art/" .. name

		return cache[name]
}

