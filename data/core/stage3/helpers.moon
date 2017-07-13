
{:Entity} = require "danmaku"

clone = (t) ->
	{key, value for key, value in pairs t}

siphon = (arg) ->
	arg or= {}

	center    = arg.from or {x:0,y:0}
	bulletData = arg.bullet or {x:100,y:100}
	rotSpeed = arg.rotSpeed or 125
	rushSpeed = arg.rushSpeed or 1/4
	
	oldUpdate  = bulletData.oldUpdate
	dx = (bulletData.x-center.x)
	dy = (bulletData.y-center.y)
	dr = math.sqrt(dx^2+dy^2)
	
	unless center
		return ->
		
	returned = false
	
	->
		unless returned
			returned = true
			
			with clone bulletData
				.update = =>
					angle = math.atan2(dy,dx)
					
					@x = (center.x + (dr - (@frame*rushSpeed)^1.1)*math.cos((@frame/rotSpeed)^1.1+angle))
					@y = (center.y + (dr - (@frame*rushSpeed)^1.1)*math.sin((@frame/rotSpeed)^1.1+angle))
					
					if math.sqrt((center.x-@x)^2+(center.y-@y)^2) < 50
						@\die!
						
{
	:siphon
}