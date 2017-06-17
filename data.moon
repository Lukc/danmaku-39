
moon = require "moonscript"

-- FIXME: love.filesystem looks completely brain damaged. Don’t use it.

filesystem = love.filesystem

local cache

modsPath = =>
	filesystem.getSaveDirectory! .. "/mods"

importTable = (t) =>
	for k, v in pairs t
		unless @[k]
			switch type(v)
				when "table"
					@[k] = {}

					importTable @[k], v
				else
					@[k] = v

defaultConfig =
	inputs: {
		{
			firing:   "y"
			bombing:  "x"
			focusing: "lshift"
			left:     "left"
			right:    "right"
			up:       "up"
			down:     "down"
		}
		{ -- FIXME: Those values suck. Also, there’s no check on their validity.
			firing:   "+"
			bombing:  "+"
			focusing: "+"
			left:     "+"
			right:    "+"
			up:       "+"
			down:     "+"
		}
		{
			firing:   "+"
			bombing:  "+"
			focusing: "+"
			left:     "+"
			right:    "+"
			up:       "+"
			down:     "+"
		}
		{
			firing:   "+"
			bombing:  "+"
			focusing: "+"
			left:     "+"
			right:    "+"
			up:       "+"
			down:     "+"
		}
	}

dumpKey = (key) ->
	switch type(key)
		when "string"
			"[\"" .. key .. "\"]"
		when "number"
			"[#{key}]"
		else
			tostring key

dump = (t, n = 0) ->
	indent = table.concat ["	" for i = 1, n]

	r = switch type(t)
		when "table"
			content = ["\t" .. indent .. dumpKey(key) .. ": " .. dump value, n+1 for key, value in pairs t]
			"{\n" .. table.concat(content) .. indent .. "}"
		when "number"
			tostring t
		when "string"
			"\"" .. t .. "\""

	return r .. "\n"

loadConfig = ->
	configFileName = filesystem.getSaveDirectory! .. "/config.moon"

	if filesystem.isFile "config.moon"
		cache.config = moon.loadfile(configFileName)!

		importTable cache.config, defaultConfig

saveConfig = ->
	configFileName = "config.moon"

	with filesystem.newFile configFileName
		\open "w"
		data = dump cache.config
		\write data, #data
		\close!

loadMod = (path) ->
	mainMoon = path .. "/main.moon"

	ok, result = pcall ->
		oldEnv = getfenv!

		chunk, err = moon.loadfile mainMoon

		unless chunk
			error "could not load the file"

		mod = (->
			-- FIXME: We should add require, but ONLY after having cleaned
			--        package.path and package.cpath.
			setfenv 1,
				:moon
				:math

			chunk!
		)!

		setfenv 1, oldEnv

		mod

	if ok
		print "Loading #{path}"

		for spellcard in *result.spellcards or {}
			table.insert cache.spellcards, spellcard
		for boss in *result.bosses or {}
			table.insert cache.bosses, boss
		for stage in *result.stages or {}
			table.insert cache.stages, stage
		for player in *result.players or {}
			table.insert cache.players, player
	else
		print "ERROR LOADING #{path}):", result

	return result

setmetatable {
	:modsPath
	:loadMod
	:loadConfig
	:saveConfig

	load: ->
		cache = {
			mods:        {}
			stages:      {}
			bosses:      {}
			spellcards:  {}
			players:     {}
			config:      {}
		}

		loadConfig!

		loadMod "./data/"

		path = "mods"

		if not filesystem.isDirectory path
			filesystem.createDirectory path

		for modPath in *filesystem.getDirectoryItems path
			loadMod modsPath! .. "/" .. modPath
}, {
	__index: (key) =>
		return cache[key]
}

