{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HeartBullet, :HugeBullet, :ArrowHeadBullet, :HeartBullet, :DiamondBullet, :StarBullet, :SquareBullet} = require "data.bullets"
-- america no seifuku
-- maya shindenno no bakuhatsu
{:radial, :circle, :sinusoid, :rotation, :row, :laser, :attachedLaser} = require "data.helpers"
{:siphon} = require "data.core.stage3.helpers"

boss1 = Spellcard {
	name: "kokoro madness"
	health: 3600
	timeout: 200 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		rayon = 100
		vart = 100
		start = 180
		t = (math.pi*@frame/vart)
		@game.boss.x = @game.width/2 + 10*16*(math.sin t)^3
		@game.boss.y = @game.height/4 - 10*(13*(math.cos t) - 5*math.cos(2*t) - 2*math.cos(3*t)-math.cos(4*t))
		radius = 80
		-- Heart Beat
		if (@frame - @spellStartFrame) % 10 == 0 and (@frame - @spellStartFrame) >= start
			@\fire HeartBullet with {}
				.outOfScreenTime = 60*60
				.color = {255,0,255}
				.speed = 0
				.radius = 9
				.x = @game.boss.x
				.y = @game.boss.y
				.angle = math.atan2(@game.boss.y-@game.height/4,@game.boss.x-@game.width/2)
				.direction = .angle
				.update = =>
					if (@game.boss.frame - @game.boss.spellStartFrame-1) % (vart*2) == start or @speed == 1
						@speed = 2
						@change = 1
					if @change == 1
						@speed -= 8/625
					if @speed < 0
						@change == 0
						@speed = 0
		if (@frame - @spellStartFrame) % (vart/2) < 38 and (@frame - @spellStartFrame) >= start and (@frame - @spellStartFrame) % 5 == 0
			for bullet in radial {bullet: {angle: @\angleToPlayer!, outOfScreenTime: 2*60}, bullets: 10,from: self, radius:20}
				@\fire ArrowHeadBullet with bullet
					.color = {@frame*40 % 255, (@frame*40 +125) % 255 , 0}
					.speed = 2
}

boss2 = Spellcard {
	name: "Explosive arrow"
	health: 3600
	timeout: 200 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		@game.boss.speed = 0.5
		@game.boss.direction = @\angleToPlayer!
		if (@frame - @spellStartFrame) % 25 == 0
			for bullet in radial {bullet: {angle: @\angleToPlayer!, outOfScreenTime: 2*60}, bullets: 6,from: self, radius:1}
				@\fire ArrowHeadBullet with bullet
					.color = {@frame*40 % 255, (@frame*40 +125) % 255 , 0}
					.speed = 3
					distVal = Entity.distance(@game.boss,@game.players[1])/.speed
					.update = =>
						if @speed > 0
							if @frame > distVal
								@speed = 0
						if @frame == 400
							@game.boss\fire BigBullet with {}
								.color = @color
								.x = @x
								.y = @y
								.speed = 0
								.angle = 0
								.radius = -10
								.direction = 0
								.update = =>
									@radius += 2
									if @frame == 20
										@\die!
							@\die!
}

boss3 = Spellcard {
	name: "Bouncing arrows"
	health: 3600
	timeout: 200 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		if (@frame - @spellStartFrame) % 100 == 0
			for bullet in radial {bullet: {angle: (math.pi*((@frame- @spellStartFrame)*153)/3578), outOfScreenTime: 2*60}, bullets: 8,from: self, radius:4}
				@\fire ArrowHeadBullet with bullet
					.speed = 2
					.color = {255,0,255}
					.radius = 2
					.update = =>
						if not @lasts
							@lasts = 1
						if (@x < 0 or @x > @game.width) and @frame > (@lasts +3)
							@angle = math.pi-@angle
							@direction = @angle
							@radius += 0.4
							@speed -= 0.1
							@lasts = @frame
							@color[2] += 60
							@color[3] -= 60
							
						if (@y < 0 or @y > @game.height) and @frame > (@lasts +3)
							@angle = -@angle
							@direction = @angle
							@radius += 0.4
							@speed -= 0.1
							@lasts = @frame
							@color[2] += 60
							@color[3] -= 60
						if @radius > 4
							@\die!
}



boss4 = Spellcard {
	name: "Non-Spell"
	health: 3600
	timeout: 200 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		if (@frame - @spellStartFrame) % 60 == 0 and (@frame - @spellStartFrame) % 400 < 300
			varAngle = (math.random() - 0.5)
			@\fire ArrowHeadBullet with {}
				.speed = 5
				.angle = 0
				.direction = .angle + varAngle
				.color = {0,142,241}
				.update = =>
					if @frame%5 ==0
						savedTime = @frame
						@game.boss\fire HeartBullet with {}
							.color = {255,0,255}
							.x = @x
							.y = @y
							.y += math.random()*200 -100
							.speed = 0
							.angle = math.pi/2
							.direction = .angle
							.update = =>
								if (@frame + savedTime) == 80
									@ready = true
									@speed = 4
								if @ready
									@speed = math.abs((@y-@game.players[1].y)/@game.height)+2
			
}

boss5 = Spellcard {
	name: "No kitten were harmed"
	health: 3600
	timeout: 200 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		ratio = 1/400
		if (@frame - @spellStartFrame) % 1 == 0
			@\fire HugeBullet with {}
				.speed = 4
				.angle = math.random()*math.pi*2
				.direction = .angle
				.color = {0,142,241,155}
				.radius = 5
				.update = =>
					if not @maxSpeed
						@maxSpeed = math.random()+3
					@speed = math.cos(@frame/50)*@maxSpeed/4+3*@maxSpeed/4
		if (@frame - @spellStartFrame) % 20 == 0
			for bullet in radial {bullet: {angle: math.pi*((@frame - @spellStartFrame)*ratio), outOfScreenTime: 2*60}, bullets: 5,from: self, radius:4}
				@\fire SmallBullet with bullet
					.speed = 2
					.color = {255,142,0}
			for bullet in radial {bullet: {angle: -math.pi*((@frame - @spellStartFrame)*ratio), outOfScreenTime: 2*60}, bullets: 5,from: self, radius:4}
				@\fire SmallBullet with bullet
					.speed = 2
					.color = {255,142,0}
		if (@frame - @spellStartFrame) % 80 == 0
			for bullet in radial {bullet: {angle: -math.pi*((2*@frame - @spellStartFrame)*ratio), outOfScreenTime: 2*60}, bullets: 60,from: self, radius:4}
				@\fire SmallBullet with bullet
					.speed = 2
					.radius = 10
					.color = {142,255,0}
					if (@frame - @spellStartFrame) % 160 == 80
						.color = {255,142,255}
					oldUpdate = .update
					.update = =>
						if oldUpdate
							oldUpdate self
						if @radius > 10
							@radius -= 1
						t = @angle % (2*math.pi)
						r = (math.pi*(@game.boss.frame+@frame)/200) % (2*math.pi)
						s = r + math.pi/4
						t2 = (@angle + math.pi) % (2*math.pi)
						r2 = (math.pi*(@game.boss.frame+@frame)/200 + math.pi) % (2*math.pi)
						s2 = r2 + math.pi/4
						if (s > t and t > r) or (s2 > t2 and t2 > r2 and r>math.pi)
							@radius += 1.5
}

boss6 = Spellcard {
	name: "Explooooosion !"
	health: 3600
	timeout: 200 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		if (@frame - @spellStartFrame) == 20
			for bullet in radial {bullet: {angle: 0, outOfScreenTime: 2*60}, bullets: 3,from: self, radius:4}
				@game.boss\fire HugeBullet with bullet
					.color = {0,255,0}
					.speed = 4
					print .angle
					if .angle < math.pi
						.color = {255,0,0}
					if .angle > math.pi*3/2
						.color = {0,0,255}
					oldUpdate = .update
					.update = =>
						if oldUpdate
							oldUpdate self
						if @speed == 0
							@speed = 30
							@direction = math.random()*math.pi*2+math.random()/50
						if (@x < 5 or @x > @game.width-5)
							@direction = math.pi-@direction+math.random()/50
							@firing = true			
						if (@y < 5 or @y > @game.height-5)
							@direction = -@direction
							if @y >5
								@firing = true
						if @firing
							@firing = false
							@game.boss\fire HugeBullet with {}
								.speed = 0
								.radius = 2
								.color = @color
								.x = @x
								.y = @y
								.angle = 0
								.direction = 0
								.update = =>
									@radius += 0.1
									if @radius >= 35 and not @dying
										for bullet in radial {bullet: {angle: 0, outOfScreenTime: 2*60}, bullets: 40,from: self, radius:4}
											@game.boss\fire SmallBullet with bullet
												.color = @color
												.speed = 2
										@\die!
				
}

----------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Stage 3 midBoss Spellcards ---------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

midBoss1 = Spellcard {
	name: "Maelstrom gate"
	health: 3600
	timeout: 60 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		if not @first and (@frame %50) <12
			@first = true
			print @first
			print (@frame %50)
		anglec = 2*@frame/125
		center = {x:@x,y:@y}
		rs = 1
		if @game.difficulty >3
			rs = 0.4
		if @first and @frame % 2 == 0 and @frame % 50 > 12
			portal = false
			if @frame % 50 == 48 or @frame %50 == 14
				portal = true
			for bullet in radial {bullet: {angle: anglec, outOfScreenTime: 30*60}, bullets: 3,from: center, radius: 600}
				for bullet in siphon {from:center, :bullet,rushSpeed:1,rotSpeed:1/(300*rs)}
					@\fire SmallBullet with bullet
						.color = {0, 100, 255}
						.speed = 2
						.radius = 4
						if portal == true
							.radius = 9
							.color = {255,100,0}
		@lapse = 6
		anglec = (@frame % 50)*math.pi*2/150
		if @game.difficulty > 2
			@lapse = 4
		if @frame % @lapse == 0 and @frame %100 > 50
			for bullet in radial {bullet: {angle: anglec, outOfScreenTime: 30}, bullets: 3,from: center, radius: 100}
				@\fire SmallBullet with bullet
					.color = {50,50,255}
					if .angle == anglec + math.pi*4/3
						.color = {50, 255, 50}
					if .angle == (anglec + math.pi*2/3)
						.color = {255,105,180}
					.speed = 2
					if @game.difficulty > 3
						.speed = 1
					.radius = 5
}

midBoss2 = Spellcard {
	name: "Maelstromic gate"
	health: 3600
	timeout: 50 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		rotSpeed = 0.0005*math.pi
		if (@frame - @spellStartFrame) %800 == 0
			for bullet in radial {bullet: {angle: math.pi/3, outOfScreenTime: 50*60}, bullets: 3,from: self, radius: 80}
				for bullet in siphon {from:@game.boss, bullet:{x:bullet.x,y:bullet.y, outOfScreenTime: 5*60}, rushSpeed:-2, :rotSpeed}
					@\fire SquareBullet with bullet
						.color = {255, 0 , 255}
						.speed = 1
						.radius = 20
						oldUpdate = .update
						.update = =>
							@angle=@frame/20
							if oldUpdate
								oldUpdate self
							if @frame % 8 == 0 and not (@frame % 100 > 70 and @frame % 100 < 100)
								for bullet in siphon {from:@game.boss, bullet:{x:@x,y:@y, outOfScreenTime: 60*60}, rushSpeed:0, :rotSpeed}
									@game.boss\fire SmallBullet with bullet
										.color = {255, 0, 0}
										.speed = 0
										olddUpdate = .update
										.update = =>
											if olddUpdate
												olddUpdate self
											if (@frame +1) % 2000 == 0 and not @dying
												@\die!
						
							if @frame % 45 == 30 and @game.boss.frame < 800
								for bullet in radial {bullet: {angle: 2*math.pi/3, outOfScreenTime: 50*60}, bullets: 20,from: @game.boss, radius: Entity.distance(self,@game.boss)}
									for bullet in siphon {from:@game.boss, bullet:{x:bullet.x,y:bullet.y, outOfScreenTime: 60*60}, rushSpeed:0, rotSpeed: -math.pi*rotSpeed}
										@game.boss\fire SmallBullet with bullet
											.speed = 0
											.radius = 6
											.color = {200,142,0}
		if (@frame - @spellStartFrame) %800 == 400
			for bullet in radial {bullet: {angle: 2*math.pi/3, outOfScreenTime: 50*60}, bullets: 3,from: self, radius: 80}
				for bullet in siphon {from:@game.boss, bullet:{x:bullet.x,y:bullet.y, outOfScreenTime: 5*60}, rushSpeed:-2, :rotSpeed}
					@\fire SquareBullet with bullet
						.color = {255, 0 , 255}
						.speed = 1
						.radius = 20
						oldUpdate = .update
						.update = =>
							@angle=@frame/20
							if oldUpdate
								oldUpdate self
							if @frame % 8 == 0 and not(@frame % 100 > 30 and @frame % 100 < 60)
								for bullet in siphon {from:@game.boss, bullet:{x:@x,y:@y, outOfScreenTime: 60*60}, rushSpeed:0, :rotSpeed}
									@game.boss\fire SmallBullet with bullet
										.color = {255, 255, 0}
										.speed = 0
										olddUpdate = .update
										.update = =>
											if olddUpdate
												olddUpdate self
											if (@frame +1) % 2000 == 0 and not @dying
												@\die!
}

midBoss3 = Spellcard {
	name: "Maelstromic circle of luv"
	difficulties: {
		Difficulties.Normal
	}
	description: "a spiral"
	health: 1000
	timeout: 40 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	update: =>
		center = {x:@game.width/2,y:@game.height/4}
		anglec = math.pi/7 - 2*@frame/125
		for i=1,5
			if (@frame + i*20) % 200 == 0
				for bullet in radial {bullet: {angle:anglec, outOfScreenTime: 5}, bullets: 20,from: center, radius: 100}
					@\fire SmallBullet with bullet
						.color = {100, 100, 5*(@frame-i*20) % 256 +80}
						.speed = 2
						.radius = 4
						oldUpdate = .update
						.update = =>
							@angle += Entity.distance(self,center)/(500*@frame+1)
							@direction = @angle
							if oldUpdate
								oldUpdate self
				for bullet in radial {bullet: {angle:anglec, outOfScreenTime: 5}, bullets: 20,from: center, radius: 100}
					@\fire SmallBullet with bullet
						.color = {100, 100, 5*(@frame-i*20) % 256 +80}
						.speed = 2
						.radius = 4
						oldUpdate = .update
						.update = =>
							@angle -= Entity.distance(self,center)/(500*@frame+1)
							@direction = @angle
							if oldUpdate
								oldUpdate self
						
		if @frame % 80 == 0
			anglec = math.pi/7 - 2*@frame/125
			for bullet in radial {bullet: {angle: anglec, outOfScreenTime: 30*60}, bullets: 5,from: center, radius: 600}
				for bullet in siphon {from:center, :bullet}
					@\fire SmallBullet with bullet
						.color = {100, 100, 5*@frame % 256 +80}
						.speed = 2
}

midBoss4 = Spellcard {
	name: "Non-Spell"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 3600
	timeout: 36 * 60
	update: =>
		h = @game.height
		w = @game.width
		-- Flower spell card
		if (@frame - @spellStartFrame) == 100
			for bullet in *{{x:5,y:h/4},{x:5,y:2*h/4},{x:5,y:3*h/4},{x:w-5,y:h/4},{x:w-5,y:2*h/4},{x:w-5,y:3*h/4}}
				@\fire HugeBullet with bullet
					.speed = 0
					.update = =>
						if not @baseY
							@baseY = @y
						@y = @baseY+h*math.cos(@frame/200)/4
						if @frame %80 == 0
							for bullet in radial {from: self, bullets: 20, bullet:{outOfScreenTime:60*5},radius:0}
								@game.boss\fire SmallBullet with bullet
									.color = {204, 0, 0}
									.speed = 2
									.radius = 4
									.x = @x
									.y = @y
}

midBoss5 = Spellcard {
	name: "Explosive Barrel"
	difficulties: {
		Difficulties.Normal
	}
	description: "a spiral"
	health: 60 * 60 * 60 * 60
	timeout: 30 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	update: =>
		anglec = math.pi/137 + @frame*math.pi/943
		center = {x:@x,y:@y}
		if @frame % 40 == 0
			for bullet in radial {bullet: {angle:anglec, outOfScreenTime: 5}, bullets: 3,from: center, radius: 50}
				@\fire SmallBullet with bullet
					.color = {math.min(100+@frame,255), math.max(0,@frame+100), 5*@frame % 256 +80}
					.speed = 2
					.radius = 4
					oldUpdate = .update
					.update = =>
						@angle += Entity.distance(self,center)/(600*@frame+1)
						@direction = @angle
						if oldUpdate
							oldUpdate self
			for bullet in radial {bullet: {angle:anglec, outOfScreenTime: 5}, bullets: 3,from: center, radius: 50}
				@\fire SmallBullet with bullet
					.color = {100, 100, 5*@frame % 256 +80}
					.speed = 2
					.radius = 4
					oldUpdate = .update
					.update = =>
						@angle -= Entity.distance(self,center)/(600*@frame+1)
						@direction = @angle
						if oldUpdate
							oldUpdate self
		if @frame %100 == 0
			for bullet in radial {bullet: {angle: anglec, outOfScreenTime: 30*60}, bullets: 3,from: center, radius: 5}
				@\fire SmallBullet with bullet
					.color = {math.min(@frame/3,255), math.max(0,100-@frame/3), math.max(0,255-@frame/3)}
					.speed = 1
					.radius = 20
					oldUpdate = .update
					.update = =>
						if oldUpdate
							oldUpdate self
						if Entity.distance(self,center) > 347
							if not @dying
								for bullet in radial {bullets:30, from:self, radius:5}
									@game.boss\fire SmallBullet with bullet
										.color = {255, 0, 0}
										.speed = @frame/50 % 5
								@\die!
}

{
	midBoss1,midBoss2,midBoss3,midBoss4,midBoss5,boss1,boss2,boss3,boss4,boss5,boss6
}