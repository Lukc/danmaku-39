
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
	health: 3600
	timeout: 30 * 60
	update: =>
		-- Flower spell card
		if @frame % 6 == 0
			direction1 = math.pow(@frame, 2)*(math.pow(@x, 2) + math.pow(@y, 2))
			direction2 = math.pow((math.pow(@x, 2)+math.pow(@y, 2) - @frame * @x),2)
			direction3 = -(math.pow(@frame, 2)*(math.pow(@x, 2) + math.pow(@y, 2)))
			direction4 = -(math.pow(@frame, 2)*(math.pow(@x, 2) + math.pow(@y, 2)))*2

			--green
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire BigBullet with bullet
					.color = {204, 0, 0}
					.speed = 8
					.direction = direction1
			-- red
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire BigBullet with bullet
					.color = {0, 255, 0}
					.speed = 6
					.direction = direction2
			-- blue
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire BigBullet with bullet
					.color = {51, 255, 255}
					.speed = 6
					.direction = direction3
			-- purple
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire BigBullet with bullet
					.color = {102, 0, 102}
					.speed = 7
					.direction = direction4
}

s2 = Spellcard {
	name: "[Wise Sign] Calling the Brotherhood"
	difficulties: {
		Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60
	update: =>
		if @frame % 5 == 0
			bullet =
				speed: 5
				direction:  @frame / 2 * math.pi / 8
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

s4 = Spellcard {
	name: "[Owl Sign] Eye of the Night"
	difficulties: {
		Difficulties.Lunatic
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

s6 = Spellcard {
	name: "[Shaman Sign] Serpents of the Sun"
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

s8 = Spellcard {
	name: "[Fire Sign] Descending Spear"
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

s10 = Spellcard {
	name: "[Fire Sign] Godly Artefact"
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

