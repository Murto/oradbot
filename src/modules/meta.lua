local command = require("../command")
local embed = require("../embed")
local global = require("../global")
local module = require("../module")

assert(global.mod_man, "Missing module manager")


local load = command:new("load", function(msg, name)
		local status, reason = pcall(function() global.mod_man:load(name) end)
		if (not status)  then
			error(name .. " was not loaded, reason: " .. reason)
		end
		msg:reply(embed:new(name .. " loaded", 0x00BB00))
	end, 100)

local unload = command:new("unload", function(msg, name)
		local status, reason = pcall(function() global.mod_man:unload(name) end)
		if (not status) then
			error(name .. " was not loaded, reason: " .. reason)
		end
		msg:reply(embed:new(name .. " unloaded", 0x00BB00))
	end, 100)

local reload = command:new("reload", function(msg, name)
		local status, reason = pcall(function() global.mod_man:reload(name) end)
		if (not status) then
			error(name .. " was not reloaded, reason: " .. reason)
		end
		msg:reply(embed:new(name .. " reloaded", 0x00BB00))
	end, 100)


local name = "Meta"
local desc = "Metamodule for managing modules"


return module:new(name, desc, {load, unload, reload}, nil)
