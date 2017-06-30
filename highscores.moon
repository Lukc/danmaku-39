
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

scoreMatches = (score, stage, players, options) ->
	if stage.name and score.stage != stage.name
		print "Stage mismatch."
		return false

	for i, player in ipairs players
		character = score.characters[i]

		unless character
			print "Character mismatch."
			return false

		unless character.name == player.name
			print "Character mismatch."
			return false

		unless character.variant == player.secondaryAttackName
			print "Variant mismatch (#{character.variant}, #{player.secondaryAttackName})."
			return false

	for option, value in pairs options
		if type(value) == "table"
			continue

		if score.options[option] != value
			print "Option (#{option}) mismatch."
			return false

	return true

setmetatable {
	load: ->
		cache = {}

		if not filesystem.exists "scores.moon"
			print "No previous scoresfile."
			return

		success, value = pcall ->
			moon.loadfile(scoresFile)!

		if success
			print "Highscores loaded."
			cache = value

			value
		else
			print "Loading highscores failed…"
			print value

	get: (stage, players, options) ->
		for score in *cache
			if scoreMatches score, stage, players, options
				return score.score

		return 0

	get10: (stage, players, options) ->
		scores = {}

		for score in *cache
			if scoreMatches score, stage, players, options
				table.insert scores, score

				if #scores >= 10
					return scores

		scores

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

