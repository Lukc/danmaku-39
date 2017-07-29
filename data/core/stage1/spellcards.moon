
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
		if f % 50 == 0
			for bullet in radial{bullets: 60, from: self, radius: 40, bullet: {angle:@frame/20}}
				@\fire SmallBullet with bullet
					.color = {255,180,180}
					.radius = 5
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
							@angle -= math.sqrt(50*math.abs(@angle-finalAngle))*(@angle-finalAngle)/math.abs(@angle-finalAngle)/300
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
							@angle -= math.sqrt(50*math.abs(@angle-finalAngle))*(@angle-finalAngle)/math.abs(@angle-finalAngle)/300
		if f == 50
			for i = 0,5
				@\fire SmallBullet with {}
					.color = {50,255,255}
					.x = @game.width*11/10
					.y = @game.height*(1+i)/5
					.speed = 0
					.outOfScreenTime = 60*20
					.radius = 10
					.living = =>
						yTarget = @game.height*(1+i)/5
						if @x != @game.width*9/10
							@x -= @game.width/200
						if @x == @game.width*9/10
							@y -= @game.height*math.sin(@frame/50)/1000
							@y -= @game.height*math.sin(@frame/50)/1000
							if @frame %200 == 100
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
											if @width == 20282
												@touchable = true
											if @frame == 150
												@\die!
			for i = 0,5
				@\fire SmallBullet with {}
					.color = {50,255,255}
					.x = -@game.width*1/10
					.y = @game.height*(1+i)/5
					.speed = 0
					.outOfScreenTime = 60*20
					.radius = 10
					.living = =>
						yTarget = @game.height*(1+i)/5
						if @x != @game.width*1/10
							@x += @game.width/200
						if @x == @game.width*1/10
							@y -= @game.height*math.sin(@frame/50)/1000
							@y -= @game.height*math.sin(@frame/50)/1000
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
			for bullet in radial {bullets: 20, from: self, radius: 80, bullet:{angle:@game.boss\angleToPlayer!+math.random()}}
				@\fire SmallBullet with bullet
					.color = {180,80,180}
					.speed = 4
					.outOfScreenTime = 60*20
					.living = =>
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
			for bullet in radial {bullets: 20, from: self, radius: 80, bullet:{angle:@game.boss\angleToPlayer!+math.random()}}
				@\fire SmallBullet with bullet
					.color = {180,80,180}
					.speed = 4
					.outOfScreenTime = 60*20
					.living = =>
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
	name: "tar"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 40 * 60

	update: =>
		f = @frame - @spellStartFrame
		if not @origin
			@origin = {x:@x,y:@y}
			
		g = (f/100 % 2)*math.pi
		w = @game.width/5
		r = w + w*math.cos(2*g)
		@x = @origin.x + r*math.cos(g)
		@y = @origin.y + r*math.sin(g)

		bullet = {
			color: {0, 204, 0},
			speed: 0 + @game.difficulty
			anglec: math.pi/7 - 2*@frame/125
		}
		
		if f % 40 == 0
			a = @\angleToPlayer!
			for j = -1,3
				for i = 1,5
					@\fire DiamondBullet with {}
						.color = {80,255,100}
						.x = @x + math.cos(a+(j-1)/2+(3-i)/10)*(100-5*((3-i)^2))
						.y = @y + math.sin(a+(j-1)/2+(3-i)/10)*(100-5*((3-i)^2))
						.angle = a+(j-1)/2
						.radius = 4
						.speed = 2
						.direction = a+(j-1)/2
		
		--Centre du tir des yeux
		@p1 = {x:@origin.x+w*2,y:@origin.y,speed:0}
		@p2 = {x:@origin.x-w*2,y:@origin.y,speed:0}
		
		if f == 20
			@\fire SmallBullet with @p1
				.angle = 0
			@\fire SmallBullet with @p2
				.angle = 0
		
		--Yeux rouges du hiboux
		if f % 100 == 0
			for bullet in radial {bullets: 20, from: @p1, radius: 80, bullet:{angle:@game.boss\angleToPlayer!+math.random()}}
				@\fire DiamondBullet with bullet
					.color = {255,100,80}
					.speed = 4
					.outOfScreenTime = 60*20
					.living = =>
						if not @bossX
							@bossX = @game.boss.p1.x
							@bossY = @game.boss.p1.y
						if @frame == 100
							@speed = 2
						@angle -= 0.03
						d = math.atan2(@y-@bossY,@x-@bossX) % (2*math.pi)
						t = (math.pi-d+@angle) % (math.pi*2)
						if t <= math.pi*20/32
							@angle += 0.03
							
						@angle = @angle % (math.pi*2)
						@direction = @angle
		
		--Yeux bleus du hiboux
		if f % 100 == 50
			for bullet in radial {bullets: 20, from: @p2, radius: 80, bullet:{angle:@game.boss\angleToPlayer!+math.random()}}
				@\fire DiamondBullet with bullet
					@color = {80,100,255}
					.speed = 4
					.outOfScreenTime = 60*20
					.living = =>
						if not @bossX
							@bossX = @game.boss.p2.x
							@bossY = @game.boss.p2.y
						if @frame == 100
							@speed = 2
						@angle += 0.03
						d = math.atan2(@y-@bossY,@x-@bossX) % (2*math.pi)
						t = (math.pi-d+@angle) % (math.pi*2)
						if t >= math.pi*44/32
							@angle -= 0.03
							
						@angle = @angle % (math.pi*2)
						@direction = @angle
}

s4 = Spellcard {
	name: "nonSpell"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}

	health: 1800
	timeout: 40 * 60

	update: =>
		f = @frame - @spellStartFrame
		
		if f % 100 == 20
			for bullet in radial {bullets: 20, from: self, radius: 80}
				@\fire SmallBullet with bullet
					.radius = 10
					.speed = 50
					.living = =>
						@angle -= 0.05
						@speed = 1
						d = math.atan2(@y-@game.boss.y,@x-@game.boss.x) % (2*math.pi)
						t = (math.pi-d+@angle) % (math.pi*2)
						if t <= math.pi*16/32
							@angle += 0.05
						@angle = @angle % (math.pi*2)
						@direction = @angle
						if @frame % 10 == 0
							@color = {120*math.random(0,2),120*math.random(0,2),120*math.random(0,2)}
						if @frame == 100
							@\die!
					
		
		if f % 20 == 0
			a = f/200
			for j = -5,7
				for i = 1,5
					@\fire DiamondBullet with {}
						.x = @x + math.cos(a+(j-1)/2+(3-i)/10)*(100-5*((3-i)^2))
						.y = @y + math.sin(a+(j-1)/2+(3-i)/10)*(100-5*((3-i)^2))
						.angle = a+(j-1)/2
						.radius = 4
						.speed = 4
						.direction = a+(j-1)/2
						.living = =>
							@color = {math.random(0,255),math.random(0,255),math.random(0,255)}
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

	living: =>
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

	living: =>
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

	living: =>
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

	--living: =>
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

	living: =>
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

	--living: =>
		--//TODO
		--need lazer like
}

{
	midBoss1, midBoss2, midBoss3, s4, s5, s6, s7, s8, s9, s10
}

