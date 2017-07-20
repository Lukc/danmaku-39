
{:Entity} = require "danmaku"

clone = (t) ->
	{key, value for key, value in pairs t}

siphon = (arg) ->
	arg or= {}

	center    = arg.from or {x:0,y:0}
	bulletData = arg.bullet or {x:100,y:100}
	rotSpeed = arg.rotSpeed or 1/125
	rushSpeed = arg.rushSpeed or 1/4
	disapearRange = arg.disapear or 50
	
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
					if not @angles
						@angles = math.atan2(dy,dx)
					@x = (center.x + (dr - @frame*rushSpeed)*math.cos(@frame*rotSpeed+@angles))
					@y = (center.y + (dr - @frame*rushSpeed)*math.sin(@frame*rotSpeed+@angles))
					if math.sqrt((center.x-@x)^2+(center.y-@y)^2) < disapearRange and rushSpeed > 0
						@\die!
						
{
	:siphon
}