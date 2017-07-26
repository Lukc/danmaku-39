
{
	:Entity, :Enemy
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{
	:BigBullet, :SmallBullet, :SimpleBullet, :MiniBullet, :HugeBullet
	:DiamondBullet
	:ArrowHeadBullet
} = require "data.bullets"

{:radial, :circle, :sinusoid, :column, :row, :attachedLaser} = require "data.helpers"

-- Defining Xuhe SpellCards
	-- s1: 1rst attack (N/H/L)
	-- s2: [Wise Sign] Calling the Brotherhood (L)
	-- s3: 2nd attack (N/H/L)
	-- s4: [Owl Sign] Eye of the Night (H/L)

midBoss1 = Spellcard {
	name: "tudu"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 1800
	timeout: 60 * 60

	update: =>
		f = @frame - @spellStartFrame
		if f == 50
			for i = 0,5
				@\fire attachedLaser
					from: {x: @game.boss.x+20+5*i,y: @game.boss.y+40-20*i,radius: 0}
					bullet:
						color: {255,150,150}
						angle: 0
						w: 5
						h: 800
						radius: 0
						damageabe: false
						living: =>
							finalAngle = -math.pi*42/30
							@angle -= math.sqrt(math.abs(@angle-finalAngle))*(@angle-finalAngle)/math.abs(@angle-finalAngle)/300
				@\fire attachedLaser
					from: {x: @game.boss.x-20-5*i,y: @game.boss.y+40-20*i,radius: 0}
					bullet:
						color: {255,150,150}
						angle: -math.pi
						w: 5
						h: 800
						radius: 10
						damageabe: false
						living: =>
							finalAngle = math.pi*12/30
							@angle -= math.sqrt(math.abs(@angle-finalAngle))*(@angle-finalAngle)/math.abs(@angle-finalAngle)/300
		if f == 50
			for i = 0,20
				@\fire SmallBullet with {}
					.color = {50,255,255}
					.x = @game.width*9/10
					.y = 5
					.speed = 0
					.outOfScreenTime = 60*20
					.radius = 10
					.living = =>
						yTarget = @game.height*(5+i)/22
						yLarg = @game.height*5/11
						if not @movement and @y > yTarget
							@movement = 0
							@isMoving = true
						if @y < yTarget
							@y -= math.sqrt(math.abs(@angle-yTarget))*(@angle-yTarget)/math.abs(@angle-yTarget)/5
						if (@game.frame % 200) > 37 and @movement
							@y += math.sin(@movement)*yLarg/326
							@movement += 13*math.pi/163
						if (@game.frame % 200) == 0 and @isMoving
							@isMoving = false
							@firing = true
						if (@game.frame % 200) == 50
							@isMoving = true
						if (@game.frame % 200) == 5 and @firing
							@radius = 10
							@firing = false
							@game.boss\fire attachedLaser
								from: self
								bullet:
									color: {255,150,150}
									angle: math.pi
									speed: 0
									w: 2
									h: @game.width*4/5
									touchable: false
									living: =>
										if @width < 5
											@width += 0.5
										if @width == 5
											@touchable = true
										if @frame == 20
											@\die!
			for i = 0,20
				@\fire SmallBullet with {}
					.color = {50,255,255}
					.x = @game.width/10
					.y = 5
					.speed = 0
					.radius = 10
					.outOfScreenTime = 60*20
					.living = =>
						yTarget = @game.height*(5+i)/22
						yLarg = @game.height*5/11
						if not @movement and @y > yTarget
							@movement = 0
							@isMoving = true
						if @y < yTarget
							@y -= math.sqrt(math.abs(@angle-yTarget))*(@angle-yTarget)/math.abs(@angle-yTarget)/5
						if (@game.frame % 200) > 37 and @movement
							@y += math.sin(@movement)*yLarg/326
							@movement += 13*math.pi/163
						if (@game.frame % 200) == 0 and @isMoving
							@isMoving = false
							@firing = true
						if (@game.frame % 200) == 50
							@isMoving = true
}

midBoss2 = Spellcard {
	name: "Call to the Flock"
	sign: "Wisdom"
	difficulties: {
		Difficulties.Lunatic
	}
	health: 3600
	timeout: 40 * 60
	update: =>
		f = @frame - @spellStartFrame
		if f % 100 == 20
			for bullet in radial {bullets: 12, from: self, radius: 80, bullet:{angle:@game.boss\angleToPlayer!+math.random()}}
				@\fire SmallBullet with bullet
					.color = {180,80,180}
					.speed = 4
					.outOfScreenTime = 60*20
					.update = =>
						fVar = @game.boss\angleToPlayer! % (math.pi*2)
						if fVar >= math.pi/2
							@angle += 0.05
							@speed = 1
						if fVar < math.pi/2
							@angle -= 0.05
							@speed = 1
						d = math.atan2(@y-@game.boss.y,@x-@game.boss.x) % (2*math.pi)
						t = (math.pi-d+@angle) % (math.pi*2)
						if t <= math.pi*18/32
							@angle += 0.05
						if t > math.pi*46/32
							@angle -= 0.05
						if (t <= math.pi*18.5/32) or (t > math.pi*45.5/32)
							@speed = 5
						@angle = @angle % (math.pi*2)
						@direction = @angle
						@color = {200*t/math.pi,255-200*t/math.pi,255-200*t/math.pi}
		if f % 100 == 70
			for bullet in radial {bullets: 12, from: self, radius: 80, bullet:{angle:@game.boss\angleToPlayer!+math.random()}}
				@\fire SmallBullet with bullet
					.color = {180,80,180}
					.speed = 4
					.outOfScreenTime = 60*20
					.update = =>
						fVar = @game.boss\angleToPlayer! % (math.pi*2)
						if fVar >= math.pi/2
							@angle -= 0.05
							@speed = 1
						if fVar < math.pi/2
							@angle += 0.05
							@speed = 1
						d = math.atan2(@y-@game.boss.y,@x-@game.boss.x) % (2*math.pi)
						t = (math.pi-d+@angle) % (math.pi*2)
						if t <= math.pi*18/32
							@angle += 0.05
						if t > math.pi*46/32
							@angle -= 0.05
						if (t <= math.pi*18.5/32) or (t > math.pi*45.5/32)
							@speed = 5
						@angle = @angle % (math.pi*2)
						@direction = @angle
						@color = {200*t/math.pi,255-200*t/math.pi,255-200*t/math.pi}
}

midBoss3 = Spellcard {
	name: nil
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 40 * 60
	bool: 0

	update: =>
		@\roam {180, 180, 80}

		bullet = {
			color: {0, 204, 0},
			speed: 0 + @game.difficulty
			anglec: math.pi/7 - 2*@frame/125
		}

		origin = {x:@x, y:@y}
		if (@frame + i*20) % 200 == 0
			for bullet in radial {bullets: 16, from: origin, radius: 100}
				@\fire SmallBullet with bullet
					oldUpdate = .update
					.direction = @\angleToPlayer!
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
	midBoss1, midBoss2, midBoss3, s4, s5, s6, s7, s8, s9, s10
}

