
moon = require "moonscript"

-- FIXME: love.filesystem looks completely brain damaged. Don’t use it.

filesystem = love.filesystem

local cache

modsPath = =>
	filesystem.getSaveDirectory! .. "/mods"

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
	else
		print "ERROR LOADING #{path}):", result

	return result

setmetatable {
	:modsPath
	:loadMod

	load: ->
		cache = {
			mods:        {}
			stages:      {}
			bosses:      {}
			spellcards:  {}
		}

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

