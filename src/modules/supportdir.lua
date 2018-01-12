local command = require("../command")
local embed = require("../embed")
local module = require("../module")

local supportdir = command:new("supportdir", function(msg)
    local str = "**Windows:**\n\t*Username\\My Documents\\OpenRA\\*\n\n"
             .. "**OS X:**\n\t*/Users/username/Library/Application Support/OpenRA/*\n\n"
             .. "**GNU/Linux:**\n\t*/home/username/.openra/*"
    msg:reply(embed:new(str, 0x00BB00))
  end, 0)

local name = "Support Directory"
local desc = "Displays the directory used for OpenRA on different systems"

return module:new(name, desc, {supportdir}, nil)
