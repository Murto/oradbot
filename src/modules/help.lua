local command = require("../command")
local embed = require("../embed")
local global = require("../global")
local module = require("../module")


assert(global.config, "Missing configuration")
local section = assert(global.config:get_section("HELP"))
local file_path = assert(section:get_property("FILE"))[1]


local help = command:new("help", function(msg)
    local file, reason = io.open(file_path)
    if (not file) then
      error(reason)
    end
    local str = file:read("*a")
    file:close()
    msg:reply(embed:new(str, 0x00BB00))
  end, 0)


local name = "Help"
local desc = "Helps users"


return module:new(name, desc, {help}, nil)
