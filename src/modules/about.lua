local command = require("command")
local embed = require("embed")
local module = require("module")
local global = require("global")

local name = "About"
local desc = "Describes the bot to users"

local about = command:new("about", function(msg)
		if (global.config) then
			local section = global.config:get_section("ABOUT")
			if (section) then
				local prop = section:get_property("FILE")
				if (prop) then
					local path = prop:get_value(1)
					if (path) then
						local file, reason = io.open(path)
						if (not file) then
							error(reason)
						end
						local str = file:read("*a")
						file:close()
						msg:reply(embed:new(str, 0x00BB00))
						return
					end
				end
			end
		end
		error("Incomplete configuration")
	end, 0)

return module:new(name, desc, {about}, nil)
