
{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HugeBullet} = require "data.bullets"

{:radial, :circle, :sinusoid, :row} = require "data.helpers"

-- Defining Panther SpellCards
	-- s1: 1rst attack (N/H/L)
	-- s3: 2nd attack (N/H/L)
	-- s2: [Jungle Sign] Prowling (N/H/L)

s1 = Spellcard {
	name: nil
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
	name: "Prowling"
	sign: "Jungle"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60

	--update: =>
}

-- Defining Teotlaco SpellCards
-- s4: 1rst attack (N/H/L)
-- s5: [Dominance Sign] Sacrifice of the Hearth (N/H/L)
-- s6: 2rst attack (N/H/L)
-- s7: [Dominance Sign] Mask of the Chief (N/H/L)
-- s8: 3rst attack (N/H/L)
-- s9: [Abundance Sign] Rain of Gold (N/H/L)
-- s10: 4rd attack (H/L)
-- s11: [Dominance Sign] Smash them! (H/L)

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
	name: "Sacrifice of the Hearth"
	sign: "Dominance"
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
	name: "Mask of the Chief"
	sign: "Dominance"
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
	name: "Rain of Gold"
	sign: "Abundance"
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
		Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}

s11 = Spellcard {
	name: "Smash them!"
	sign: "Dominance"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60

	--update: =>
}


{
	s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11
}
