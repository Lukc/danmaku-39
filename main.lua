
require "moonscript"

-- It’s a hack, and will have to be dealt with properly at some point.
if love.system.getOS() == "Windows" then
	oldOpen = io.open
	io.open = function(file, ...)
		local absolute = false

		if string.sub(file, 2, 2) == ":" then -- Windows™, duh~
			absolute = true
		end

		if not absolute then
			file = love.filesystem.getSourceBaseDirectory() .. "/danmaku-39/" .. file
		end

		return oldOpen(file, ...)
	end
end

require "game"

