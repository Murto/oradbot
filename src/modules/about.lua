local command = require("../command")
local embed = require("../embed")
local module = require("../module")
local global = require("../global")

-- Configuration loading

assert(global.config, "Missing configuration")
local section = assert(global.config:get_section("ABOUT"), "Incomplete configuration")
local file_path = assert(section:get_property("FILE"), "Incomplete configuration")[1]


-- Module commands

local about = command:new("about", function(msg)
		local file, reason = io.open(file_path)
		if (not file) then
			error(reason)
		end
		local str = file:read("*a")
		file:close()
		msg:reply(embed:new(str, 0x00BB00))
	end, 0)


-- Module creation

local name = "About"
local desc = "Describes the bot to users"

return module:new(name, desc, {about}, nil)
