local command = require("command")
local embed = require("embed")
local module = require("module")

local name = "Ping"
local desc = "A utility to test bot responsiveness"

local ping = command:new("ping", function(msg)
		local e = embed:new("pong!", 0x00FF00)
		msg:reply(e)
	end, 0)

return module:new(name, desc, {ping}, nil)
