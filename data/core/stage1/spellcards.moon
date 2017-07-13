
{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HugeBullet} = require "data.bullets"

{:radial, :circle, :sinusoid, :row} = require "data.helpers"

-- Defining Xuhe SpellCards
	-- s1: 1rst attack (N/H/L)
	-- s2: [Wise Sign] Calling the Brotherhood (L)
	-- s3: 2nd attack (N/H/L)
	-- s4: [Owl Sign] Eye of the Night (H/L)

s1 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 30 * 60
	update: =>
		bullet =
   			speed: 1 + @game.difficulty
     
		if (@frame%60 == 0) or (@frame%55 == 0)
			for bullet in row {from: self, :bullet, bullets: 13, startAngle:  (@\angleToPlayer!)-math.pi/4, endAngle: (@\angleToPlayer!)+math.pi/4}
				@\fire SmallBullet bullet
				
}

s2 = Spellcard {
	name: "[Wise Sign] Calling the Brotherhood"
	difficulties: {
		Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60
	--update: =>
		-- //TODO
}



s3 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	update: =>
		bullet = {
			angle: @\angleToPlayer!,
   			speed: 1 + @game.difficulty
     	}

		if @frame % 30 == 0
			for bullet in radial {from: self, bullets: 16, :bullet}
				@\fire BigBullet bullet
}

s4 = Spellcard {
	name: "[Owl Sign] Eye of the Night"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60
	--update: =>
		--//TODO
}

-- Defining Coactlicue SpellCards
	-- s5: 1rst attack (N/H/L)
	-- s6: [Shaman Sign] Serpents of the Sun (N/H/L)
	-- s7: 2rst attack (N/H/L)
	-- s8: [Fire Sign] Descending Spear (N/H/L)
	-- s9: 3rst attack (H/L)
	-- s10: [Fire Sign] Godly Artefact (H/L)

s5 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	--update: =>
		--//TODO
}

s6 = Spellcard {
	name: "[Shaman Sign] Serpents of the Sun"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	--update: =>
		--//TODO
}

s7 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	--update: =>
		--//TODO
}

s8 = Spellcard {
	name: "[Fire Sign] Descending Spear"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	--update: =>
		--//TODO
}

s9 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	--update: =>
		--//TODO
}

s10 = Spellcard {
	name: "[Fire Sign] Godly Artefact"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	--update: =>
		--//TODO
}

{
	s1, s2, s3, s4, s5, s6, s7, s8, s9, s10
}

