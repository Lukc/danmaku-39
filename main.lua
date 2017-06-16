
require "moonscript"

-- It’s a hack, and will have to be dealt with properly at some point.
if love.system.getOS() == "Windows" then
	oldOpen = io.open
	io.open = function(file, ...)
		file = love.filesystem.getSourceBaseDirectory() .. "/danmaku-39/" .. file

		return oldOpen(file, ...)
	end
end

require "game"

