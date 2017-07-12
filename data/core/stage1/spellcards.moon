
{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HugeBullet} = require "data.bullets"

{:radial, :circle, :sinusoid} = require "data.helpers"

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
		if @frame % 60 == 0
			bullet =
   				angle: @\angleToPlayer! --+ 30
   				speed: 1 + @game.difficulty

			
			@\fire SmallBullet bullet
			bullet.angle -= 1
			@\fire SmallBullet bullet
				
}

s2 = Spellcard {
	name: "Calling the Brotherhood"
	sign: "Wisdom"
	difficulties: {
		Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60
	update: =>
		if @frame % 5 == 0
			bullet =
				speed: 5
				angle: @\angleToPlayer!
				--green
				color: { 0,255,127 }
			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire BigBullet bullet
		if @frame % 3 == 0
			bullet =
				speed: 1.5
				direction:  @frame / 2 * math.pi / 10
				--white
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire SmallBullet bullet
}



s3 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

s4 = Spellcard {
	name: "Eye of the Night"
	sign: "Owl"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60
	update: =>
		if @frame % 40 == 0
			nbPetal = 10
			angle =  math.cos(nbPetal*@frame) + math.cos(nbPetal*@frame)--math.pi / 2 + math.pi / 6 * @frame / 10
			for bullet in radial {from: self, bullets: 8}
				for bullet in sinusoid {from: self, bullets: 1, :bullet}
					for bullet in circle {from: self, :angle, :bullet}
						@\fire HugeBullet with bullet
							.direction = 1
							.speed = 5
							.color = {
								192 + 63 * math.sin(@frame / 60 + math.pi),
								96 + 31 * math.sin(@frame / 60),
								192 + 63 * math.sin(@frame / 60),
							}
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

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

s6 = Spellcard {
	name: "Serpents of the Sun"
	sign: "Shaman"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

s7 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

s8 = Spellcard {
	name: "Descending Spear"
	sign: "Fire"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

s9 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

s10 = Spellcard {
	name: "Godly Artefact"
	sign: "Fire"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	update: =>
		if @frame % 40 == 0
			bullet =
				speed: 2.4
				direction:  @frame / 60 * math.pi / 32

			for bullet in radial {from: self, bullets: 32, :bullet}
				@\fire BigBullet bullet

		if @frame % 12 == 0
			bullet =
				speed: 3.6
				direction: math.sin((@frame - 60) / 90) * math.pi / 6 + @\angleToPlayer!
				color: {
					192 + 63 * math.sin(@frame / 60 + math.pi),
					96 + 31 * math.sin(@frame / 60),
					192 + 63 * math.sin(@frame / 60),
				}

			for bullet in radial {from: self, bullets: 8, :bullet}
				@\fire SmallBullet bullet
}

{
	s1, s2, s3, s4, s5, s6, s7, s8, s9, s10
}

