
{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HugeBullet, :DiamondBullet} = require "data.bullets"

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
	startA: 0
	endA: 0

	update: =>
		@\roam {120, 120, 80}
		bullet = {
			color: {204, 0, 204}, --light purple
			speed: 0 + @game.difficulty
		}

		if @frame%60 == 0
			@startA = (@\angleToPlayer!)-math.pi/4
			@endA = (@\angleToPlayer!)+math.pi/4
			for bullet in row {from: self, :bullet, bullets: (9+2*@game.difficulty), startAngle: @startA, endAngle: @endA}
				@\fire SmallBullet bullet
		
		if (@frame-10)%60 == 0
			for bullet in row {from: self, :bullet, bullets: (9+2*@game.difficulty), startAngle: @startA, endAngle: @endA}
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

	--b1: Entity {
	--	x: @game.width/6
	--	y: @game.height/6
	--}

	--update: =>
	--	if @frame%60 == 0
	--		@\addEntity b1

	--//TODO
	-- quand je serait faire correctement des Entités à des endroits aléatoires sur l'écran
}



s3 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60
	bool: 0

	update: =>
		@\roam {180, 180, 80}

		bullet = {
			color: {0, 204, 0},
			speed: 0 + @game.difficulty
			anglec: math.pi/7 - 2*@frame/125
		}

		origin = {x:@x, y:@y}
		for i=1,3

			if (@frame + i*20) % 200 == 0
				for bullet in radial {bullets: 12, from: origin, radius: 100}
					@\fire BigBullet with bullet
						oldUpdate = .update
						.update = =>
							@angle += Entity.distance(self,origin)/(500*@frame+1)
							@direction = @angle
							if oldUpdate
								oldUpdate self
				for bullet in radial {bullets: 16, from: origin, radius: 100}
					@\fire BigBullet with bullet
						oldUpdate = .update
						.update = =>
							@angle -= Entity.distance(self,origin)/(500*@frame+1)
							@direction = @angle
							if oldUpdate
								oldUpdate self
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
		bullet = {
			speed: 0 + @game.difficulty
		}
		centerLeft = {x:@game.width/4, y:@game.height/4}
		centerRight = {x:@game.width/4*3, y:@game.height/4}

		if @frame%60 == 0
			for bullet in row {from: centerLeft, :bullet, bullets: (2+2*@game.difficulty), startAngle: 2.09, endAngle: 1.05}
				@\fire DiamondBullet with bullet
					.color = {51, 204, 153} -- cyan
		if (@frame%60-30) == 0
			for bullet in row {from: centerRight, :bullet, bullets: (2+2*@game.difficulty), startAngle: 2.09, endAngle: 1.05}
				@\fire DiamondBullet with bullet
					.color = {255, 204, 0} -- yellow?

	-- //todo
	-- add black clouds
	-- correct origin point
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
		bullet = {
			color: {0, 204, 0}, --green
			speed: 2 + @game.difficulty
	 	}

		if @frame % 30 == 0
			for bullet in radial {from: self, bullets: 16, :bullet}
				@\fire SmallBullet bullet
		if @frame % 60 == 0
			@\fire BigBullet with bullet
				.angle = @\angleToPlayer!
				.color = {204, 0, 0} --red
				.speed = 3
}

s6 = Spellcard {
	name: "Serpents of the Sun"
	sign: "Shaman"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60
	count: 0
	stop: false

	update: =>
		angle = math.pi / 2
		
		for bullet in sinusoid {from: {x:(@game.width/4), y:0}, :angle, :bullet, reversed: true}
				@\fire SmallBullet with bullet
					.color = {255, 255, 0}
		for bullet in sinusoid {from: {x:(@game.width/2), y:0}, :angle, :bullet, reversed: true}
				@\fire SmallBullet with bullet
					.color = {255, 255, 0}
		for bullet in sinusoid {from: {x:((@game.width/4)*3), y:0}, :angle, :bullet, reversed: true}
				@\fire SmallBullet with bullet
					.color = {255, 255, 0}

	-- //TODO corriger l'origine et gérer la dispersion
}

s7 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60
	startA: 0
	endA: 0

	update: =>
		bullet = {
			color: {204, 0, 204}, --light purple
			speed: 0 + @game.difficulty
		}

		if (@frame%60 == 0)
			@startA = (@\angleToPlayer!)-math.pi/4
			@endA = (@\angleToPlayer!)+math.pi/4
			for bullet in row {from: self, :bullet, bullets: (9+2*@game.difficulty), startAngle: @startA, endAngle: @endA}
				@\fire SmallBullet bullet

		if ((@frame-5)%60 == 0) or ((@frame-10)%60 == 0) or ((@frame-15)%60 == 0)
			for bullet in row {from: self, :bullet, bullets: (9+2*@game.difficulty), startAngle: @startA, endAngle: @endA}
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

	--update: =>
		--//TODO
		-- need lazers
}

s9 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 30 * 60

	update: =>
		bullet = {
			color: {204, 0, 204}, --light purple
			speed: 0 + @game.difficulty
		}

		if (@frame%60 == 0)
			@startA = (@\angleToPlayer!)-math.pi/4
			@endA = (@\angleToPlayer!)+math.pi/4
			for bullet in row {from: self, :bullet, bullets: (9+2*@game.difficulty), startAngle: @startA, endAngle: @endA}
				@\fire SmallBullet bullet

		if ((@frame-5)%60 == 0) or ((@frame-10)%60 == 0) or ((@frame-15)%60 == 0)
			for bullet in row {from: self, :bullet, bullets: (9+2*@game.difficulty), startAngle: @startA, endAngle: @endA}
				@\fire SmallBullet bullet

		if ((@frame-30)%60 == 0)
			@\fire HugeBullet with bullet
				.color = {102, 0, 51}
				.angle = (@\angleToPlayer!)
				.speed = 1
}

s10 = Spellcard {
	name: "Godly Artefact"
	sign: "Fire"
	difficulties: {
		Difficulties.Hard, Difficulties.Lunatic
	}

	health: 3600
	timeout: 30 * 60

	--update: =>
		--//TODO
		--need lazer like
}

{
	s1, s2, s3, s4, s5, s6, s7, s8, s9, s10
}

