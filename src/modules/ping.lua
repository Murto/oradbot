local command = require("../command")
local embed = require("../embed")
local module = require("../module")


-- Module commands

local ping = command:new("ping", function(msg)
		local e = embed:new("**Pong!**", 0x00FF00)
		msg:reply(e)
	end, 0)


-- Module creation

local name = "Ping"
local desc = "A utility to test bot responsiveness"

return module:new(name, desc, {ping}, nil)
