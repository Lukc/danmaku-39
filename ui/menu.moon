
state = {}

data = require "data.main"

-- TODO: We need textures for the background, and possibly for the menu items.

Menu = require "ui.tools.menu"

local menu

state.enter = =>
	@drawTime  = 0

	menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		x: 200
		y: 200

		{
			label: "Adventure"
			onSelection: =>
				charactersList = [{
					label: "Character #{i}"
					onSelection: =>
						state.manager\setState require "ui.game"
				} for i = 1, 3]

				table.insert charactersList, {
					label: "Go back"
					onSelection: => @\setItemsList @items.parent
				}

				@\setItemsList charactersList
		}
		{
			label: "Extras"
		}
		{
			label: "Multiplayer"
		}
		{
			label: "Training"
			onSelection: {
				{
					label: "Stages"
					onSelection: =>
						list = [{
							label: "Stage #{n}, #{stage.title}"
							onSelection: =>
								print "Unimplemented."
								--state.manager\setState require "ui.game"
						} for n, stage in ipairs data.stages]

						table.insert list, {
							label: "Go back"
							onSelection: => @\setItemsList @items.parent
						}

						@\setItemsList list
				}
				{
					label: "Character"
				}
				{
					label: "Spellcards"
					onSelection: =>
						list = [{
							label: "#{spellcard.name}"
							onSelection: =>
								print "Unimplemented."
								--state.manager\setState require "ui.game"
						} for spellcard in *data.spellcards when spellcard.name]

						table.insert list, {
							label: "Go back"
							onSelection: => @\setItemsList @items.parent
						}

						@\setItemsList list
				}
				{
					label: "Go back"
					onSelection: =>
						@\setItemsList @items.parent
				}
			}
		}
		{
			label: "Highscores"
		}
		{
			label: "Replays"
		}
		{
			label: "Options"
			onSelection: {
				{
					label: "Player 1 controls"
				}
				{
					label: "Player 2 controls"
				}
				{
					label: "Player 3 controls"
				}
				{
					label: "Player 4 controls"
				}
				{
					label: "Go back"
					onSelection: =>
						@\setItemsList @items.parent
				}
			}
		}
		{
			label: "Quit"
			onSelection: =>
				love.event.quit!
		}
	}

state.keypressed = (...) =>
	menu\keypressed ...

state.draw = =>
	with c = math.min 255, @drawTime * 511
		love.graphics.setColor c, c, c

	love.graphics.print "Press “Enter” to select…", 200, 160

	menu\draw!

state.update = (dt) =>
	w, h = love.graphics.getWidth!, love.graphics.getHeight!

	x = (w - 1024) / 2
	y = (h - 800) / 2

	menu.x = x + 200
	menu.y = y + 200

	menu\update dt

state

