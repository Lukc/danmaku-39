
{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HugeBullet} = require "data.bullets"

{:radial, :circle, :sinusoid, :row} = require "data.helpers"

-- Defining Zipacna (1) SpellCards
	-- s1: [Moutain Sign] Surging from the summit (N/H/L)
	-- s2: 1rst attack (N/H/L)
	-- s3: 2nd attack + waves (N/H/L)

s1 = Spellcard {
	name: "Surging from the summit"
	sign: "Moutain"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s2 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s3 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60

	--update: =>
}

-- Defining Zipacna (2) SpellCards
-- s4: 1rst attack (N/H/L)
-- s5: [Moutain Sign] From my hands, i shaped the mountains! (N/H/L)
-- s6: 2rst attack (N/H/L)
-- s7: [Buider Sign] Enclosure (N/H/L)
-- s8: 3rst attack (N/H/L)
-- s9: [Egoism Sign] This City is MINE! (N/H/L)
-- s10: 4rd attack (N/H/L)
-- s11: [Divine Sign] Sister of the Earthquake (H/L)
-- s12: 5rd attack (H/L)
-- s13: [Builder Sign] My work is my legacy (N/H/L)

s4 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s5 = Spellcard {
	name: "From my hands, i shaped the mountains!"
	sign: "Moutain"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s6 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s7 = Spellcard {
	name: "Enclosure"
	sign: "Buider"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s8 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s9 = Spellcard {
	name: "This City is MINE!"
	sign: "Egoism"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s10 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s11 = Spellcard {
	name: "Sister of the Earthquake"
	sign: "Divine"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s12 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s13 = Spellcard {
	name: "My work is my legacy"
	sign: "Builder"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}


{
	s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13
}
