
moon = require "moonscript"

-- FIXME: love.filesystem looks completely brain damaged. Don’t use it.

filesystem = love.filesystem

local cache

scoresFile = (filesystem.getSaveDirectory!) .. "/scores.moon"

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
		when "number", "boolean"
			tostring t
		when "string"
			"\"" .. t .. "\""

	return r .. "\n"

loadMod = (path) ->
	mainMoon = path .. "/main.moon"
	oldMoonpath = package.moonpath

	ok, result = pcall ->
		oldEnv = getfenv!

		chunk, err = moon.loadfile mainMoon

		unless chunk
			error "could not load the file"

		mod = (->
			package.moonpath = "#{path}/?.moon;" .. "#{filesystem.getSaveDirectory!}/mods/?.moon;" .. oldMoonpath

			-- FIXME: We should add require, but ONLY after having cleaned
			--        package.path and package.cpath.
			setfenv 1,
				:moon
				:math
				:package
				:require
				:tostring

			chunk!
		)!

		setfenv 1, oldEnv
		package.moonpath = oldMoonpath

		mod

	if ok
		table.insert cache.mods, result

		unless result.name
			return nil, "mod is invalid (no name: field)"

		if cache.config.blockedMods[result.name]
			return nil, "mod is user-blocked"

		for spellcard in *result.spellcards or {}
			table.insert cache.spellcards, spellcard
		for boss in *result.bosses or {}
			table.insert cache.bosses, boss
		for stage in *result.stages or {}
			table.insert cache.stages, stage
		for character in *result.characters or {}
			table.insert cache.characters, character
		for variant in *result.characterVariants or {}
			table.insert cache.characterVariants, variant
	else
		print "ERROR LOADING #{path}):", result

	return result

setmetatable {
	load: ->
		cache = {}

		if not filesystem.exists scoresFile
			print "No previous scoresfile."
			return

		success, value = pcall ->
			moon.loadfile(scoresFile)!

		if success
			cache = value

			value
		else
			print "Loading highscores failed…"
			print value

	get: (stage, players, options) ->
		for score in *cache
			unless score.stage == stage.name
				continue

			print "stage name is ok"

			for i, player in ipairs players
				character = score.characters[i]

				unless character
					continue

				unless character.name == player.name
					continue

				unless character.variant == player.secondaryAttackName
					continue

			print "characters are ok"

			mismatchingOption = false
			for option, value in pairs options
				if type(value) == "table"
					continue

				if score.options[option] != value
					print "#{option} mismatch!"
					mismatchingOption = true
					break

			if mismatchingOption
				continue

			print "options are ok"

			return score.score

		return 0

	save: (stage, players, options, score, name) ->
		score = {
			stage: stage.name
			characters: [{
				name: player.name
				variant: player.secondaryAttackName
			} for player in *players]
			options: {key, value for key, value in pairs options when type(value) != "table"}
			:name, :score
		}

		table.insert cache, score

		table.sort cache, (a, b) -> a.score > b.score

		file = io.open scoresFile, "w"
		file\write dump cache
		file\close!
}, {
	__index: (key) =>
		return cache[key]
}

