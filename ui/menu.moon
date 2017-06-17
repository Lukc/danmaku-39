
{:Stage} = require "danmaku"

state = {}

data = require "data"

-- TODO: We need textures for the background, and possibly for the menu items.

Menu = require "ui.tools.menu"

gameMenu = (stage) ->
	=>
		charactersList = [{
			label: "#{player.name}"
			player: player
			onSelection: =>
				@\setItemsList with [{
					label: difficulty
					onSelection: =>
						-- FIXME: How about actually passing the difficulty?
						state.manager\setState require("ui.game"),
							stage, {player}
				} for difficulty in *{"Normal", "Hard", "Lunatic"}]
					.draw = Menu.drawCharactersList
		} for player in *data.players]

		charactersList.draw = Menu.drawCharactersList

		@\setItemsList charactersList

local menu

state.enter = =>
	@drawTime  = 0

	data.load!

	menu = Menu {
		font: love.graphics.newFont "data/fonts/miamanueva.otf", 32
		x: 200
		y: 200

		{
			label: "Adventure"
			onSelection: gameMenu(data.stages[1])
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
							label: "#{stage.title}"
							onSelection: =>
								print "Unimplemented."
								state.manager\setState require("ui.game"), stage
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
						list = {}

						for boss in *data.bosses
							for spellcard in *boss.spellcards
								unless spellcard.name
									continue

								table.insert list, {
									label: "#{spellcard.name}"
									onSelection: =>
										newState = require "ui.game"
										newStage = Stage{
											update: =>
												if @frame > 60 and #@enemies == 0
													@\endOfStage!
											[1]: =>
												@\addEntity with boss
													.spellcards = {
														spellcard
													}
										}
										state.manager\setState newState,
											newStage, {data.players[1]}
								}

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
					onSelection: =>
						list = {}

						for input in *{"up", "down", "left", "right", "firing", "bombing", "focusing"}
							table.insert list, {
								label: input
								rlabel: data.config.inputs[1][input]
								onSelection: =>
									@drawTime = 0
									print "not implemented…"
							}

						@\setItemsList list
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


