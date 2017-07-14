{
	:Entity,
	:Spellcard
	:Danmaku
} = require "danmaku"

{:Difficulties} = Danmaku

{:BigBullet, :SmallBullet, :MiniBullet, :HeartBullet, :HugeBullet} = require "data.bullets"
-- america no seifuku
-- maya shindenno no bakuhatsu
{:radial, :circle, :sinusoid, :rotation, :row} = require "data.helpers"
{:siphon} = require "data.core.stage3.helpers"
s2 = Spellcard {
	name: "Maelstrom gate"
	health: 3600
	timeout: 30 * 60
	position: => {
		x: @game.width/2
		y: @game.height/4
	}
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	update: =>
		if (@frame - @spellStartFrame) == 10
			for bullet in radial {bullet: {angle: math.pi/3, outOfScreenTime: 2*60}, bullets: 3,from: self, radius: 5}
				@\fire HugeBullet with bullet
					.color = {@frame*40 % 255, @frame*40 % 255 +80 , @frame*40 % 160}
					.speed = 3
					oldUpdate = .update
					.update = =>
						if oldUpdate
							oldUpdate self
						if @frame % 10 == 0
							for bullet in siphon {from:@game.boss, bullet:{x:@x,y:@y, outOfScreenTime: 25*60}, rushSpeed:0}
								@game.boss\fire SmallBullet with bullet
									.color = {255, 0, 0}
									.speed = 0
}

s1 = Spellcard {
	name: "Maelstrom gate"
	health: 3600
	timeout: 30 * 60
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
				for bullet in siphon {from:center, :bullet,rushSpeed:1,rotSpeed:300*rs}
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

s5 = Spellcard {
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

s3 = Spellcard {
	name: "Maelstromic circle of luv"
	difficulties: {
		Difficulties.Normal
	}
	description: "a spiral"
	health: 1000
	timeout: 60 * 60
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

s4 = Spellcard {
	name: "Annoying girl"
	difficulties: {
		Difficulties.Normal, Difficulties.Hard, Difficulties.Lunatic
	}
	health: 3600
	timeout: 30 * 60
	update: =>
		-- Flower spell card
		if @frame % 6 == 0
			direction1 = math.pow(@frame, 2)*(math.pow(@x, 2) + math.pow(@y, 2))
			for bullet in radial {from: self, bullets: 5, :bullet}
				@\fire HeartBullet with bullet
					.color = {204, 0, 0}
					.speed = 8
					.radius = 40
					.direction = direction1
}

{
	s1,s2,s3,s4
}