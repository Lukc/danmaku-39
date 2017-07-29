
cache = {
	__default: {}
}

{
	get: (name) ->
		unless cache[name]
			success, image = pcall ->
				love.graphics.newImage "data/art/" .. name

			if success
				cache[name] = image

		return cache[name]
}

