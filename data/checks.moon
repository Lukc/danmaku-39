
vt100 = love and love.system.getOS! != "Windows"

ohshit = (...) ->
	if vt100
		io.stderr\write "\027[31m"
	io.stderr\write "!! "

	for v in *{...}
		io.stderr\write tostring(v)

	if vt100
		io.stderr\write "\027[0m"

	io.stderr\write "\n"

warning = (...) ->
	if vt100
		io.stderr\write "\027[33m"
	io.stderr\write "?? "

	for v in *{...}
		io.stderr\write tostring(v)

	if vt100
		io.stderr\write "\027[0m"

	io.stderr\write "\n"

local String, Number, Boolean, Function, Table
local Or

simpleMatch = (expectation) ->
	(value) ->
		typeString = type(value)

		if typeString == expectation
			true
		else
			false, switch typeString
				when "boolean"
					Boolean
				when "string"
					String
				when "number"
					Number
				when "table"
					Table
				when "function"
					Function
				else
					typeString

String = do
	setmetatable {
		matches: simpleMatch "string"
	}, {
		__tostring: => "String"
	}
Number = do
	setmetatable {
		matches: simpleMatch "number"
	}, {
		__tostring: => "Number"
	}
Boolean = do
	setmetatable {
		matches: simpleMatch "boolean"
	}, {
		__tostring: => "Boolean"
	}
Function = do
	setmetatable {
		matches: simpleMatch "function"
	}, {
		__tostring: => "Function"
	}

Table = (Type) ->
	setmetatable {
		matches: (v) ->
			success, mismatch = simpleMatch("table")(v)
			unless success
				return false, mismatch

			unless Type
				return true

			success = true
			subtypes = {Type}

			for value in *v
				s, mismatch = Type.matches value

				unless s
					table.insert subtypes, mismatch

					success = false

			if #subtypes == 0
				true
			elseif #subtypes > 1
				success, Table(Or(unpack subtypes))
			else
				success, Table(subtypes[1])
	}, {
		__tostring: =>
			if Type
				"Table(#{Type})"
			else
				"Table()"
	}

Or = (...) ->
	Types = {...}

	setmetatable {
		name: "Or"
		matches: (v) ->
			success = false
			mismatch = nil

			for Type in *Types
				success, mismatch = Type.matches v

				if success
					break

			unless success
				return false, mismatch

			true
	}, {
		__tostring: =>
			strings = [tostring(Type) for Type in *Types]

			"Or(" .. table.concat(strings, ", ") .. ")"
	}

Mandatory = (Type) ->
	setmetatable {
		mandatory: true
		matches: (v) -> Type.matches v
	}, {
		__tostring: => tostring(Type)
	}

check = (reference) =>
	keysList = [{:key, :value} for key, value in pairs reference]

	table.sort keysList, (a, b) ->
		if type(a.key) == "string" and type(b.key) == "string"
			a.key < b.key
		else
			type(a.key) < type(b.key)

	errors = false

	for pair in *keysList
		{:key, :value} = pair

		oops = (...) ->
			if value.mandatory
				errors = true

				ohshit ...
			else
				warning ...

		keys = if key == Number
			[key for key in pairs self when type(key) == "number"]
		else
			{key}

		for key in *keys
			if not @[key]
				oops "missing '#{key}' argument"
			else
				success, mismatch = value.matches @[key]
				if not success
					errors = true

					ohshit "provided '#{key}' argument has the wrong type"
					ohshit "* #{value} expected, got #{mismatch}"

	if errors
		error "errors registered while loading data"

	self

{
	:error
	:warning

	StageData: =>
		check self, {
			title:          Mandatory(String)
			subtitle:       Mandatory(String)
			difficulties:   Mandatory(Table(Number))
			drawTitle:      Function
			drawBossData:   Function
			drawBackground: Function
			update:         Function

			[Number]:       Function
		}
	ModData: =>
		check self, {
			name:           Mandatory(String)
			bosses:         Table(Table())
			stages:         Table(Table())
			spellcards:     Table(Table())
			characters:     Table(Table())
			characterVariants: Table(Table())
		}
	BossData: =>
		check self, {
			name:           Mandatory(String)
			x:              Mandatory(Number)
			y:              Mandatory(Number)
			radius:         Number
			endOfSpell:     Function
		}
	CharacterData: =>
		check self, {
			name:           Mandatory(String)
			title:          Mandatory(String)
			mainAttackName: Mandatory(String)
			radius:         Mandatory(Number)
			itemAttractionRadius: Number
			bomb:           Function
			death:          Function
		}
	CharacterVariantData: =>
		check self, {
			name:           Mandatory(String)
			description:    Mandatory(String)
			maxPower:       Number
			update:         Function
		}
	WaveData: =>
		check self, {
			name:           String
			timeout:        Number
			update:         Mandatory(Function)
		}
}

