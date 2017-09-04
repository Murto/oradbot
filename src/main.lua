--	Required files

local config = require("config")
local command = require("command")
local default = require("default")
local discordia = require("discordia")
local global = require("global")
local matchmaker = require("matchmaker")
local utility = require("utility")
global.client = discordia.Client()


--	Bot functions

global.client:on("ready", function()
	print(string.char(27) .. "[32m[*] Connected." .. string.char(27) .. "[0m")
end)

local function split_command(p_str)
	local strs = {}
	for str in p_str:gmatch("%S+") do
		table.insert(strs, str)
	end
	return strs
end

global.client:on("messageCreate", function(p_message)
	local name, args = command.parse(p_message.content)
	if (name) then
		local status, message = command.execute(p_message, name, args)
		if (status) then
			print(string.char(27) .. "[32m[*] " .. name .. " : " .. (message or "Success.") .. string.char(27) .. "[0m")
		else
			print(string.char(27) .. "[33m[!] " .. name .. " : " .. (message or "Failure.") .. string.char(27) .. "[0m")
		end
	end
end)

global.client:on("heartbeat", function()
	matchmaker.remove_timedout()
end)


--	Command functions and wrappers

local function about(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local file = io.open(global.about_path, "r")
	if (not file) then
		p_message:reply("The about file could not be read.")
		return false, "Could not open file."
	end
	p_message:reply(file:read("*all"))
	file:close()
	return true
end

local function help(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local file = io.open(global.help_path, "r")
	if (not file) then
		p_message:reply("The help file could not be read")
		return false, "Could not open file"
	end
	p_message:reply(file:read("*all"))
	file:close()
	return true
end

local function quit(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	p_message:reply("See you next time...")
	global.client:stop(true)
	return true
end

local function config_add_option(p_option)
	if (not p_option) then
		return false, "Insufficient arguments."
	end
	p_option = p_option:upper()
	if (not config.options[p_option]) then
		config.options[p_option] = {}
		return true
	end
	return false, "Option exists."
end

local function config_add_value(p_option, p_value)
	if (not (p_option and p_value)) then
		return false, "Insufficient arguments."
	end
	p_option = p_option:upper()
	if (config.options[p_option]) then
		table.insert(config.options[p_option], p_value)
		return true
	end
	print(p_option)
	print(config.options[p_option])
	return false, "Option does not exist."
end

local function config_add(p_message, p_type, ...)
	if (not (p_message and p_type)) then
		return false, "Insufficient arguments."
	end
	p_type = p_type:lower()
	if (p_type == "option") then
		local status, message = config_add_option(...)
		if (status) then
			p_message:reply("The option was added.")
		else
			p_message:reply("The option could not be added.\nReason: " .. message)
		end
		return status, message
	elseif (p_type == "value") then
		local status, message = config_add_value(...)
		if (status) then
			p_message:reply("The value was added.")
		else
			p_message:reply("The value could not be added.\nReason: " .. message)
		end
		return status, message
	end
	p_message:reply("Nothing was added.\nReason: Unknown type.")
	return false, "Unknown type."
end

local function config_remove_option(p_option)
	if (not p_option) then
		return false, "Insufficient arguments."
	end
	p_option = p_option:upper()
	if (config.options[p_option]) then
		config.options[p_option] = nil
		return true
	end
	return false, "Option does not exist."
end

local function config_remove_value(p_option, p_value)
	if (not (p_option and p_value)) then
		return false, "Insufficient arguments."
	end
	p_option = p_option:upper()
	if (not config.options[p_option]) then
		return false, "Option does not exist."
	end
	local index = utility.find(config.options[p_option], p_value)
	if (index) then
		table.remove(config.options[p_option], index)
		return true
	end
	return false, "Value does not exist."
end

local function config_remove(p_message, p_type, ...)
	if (not (p_message and p_type)) then
		return false, "Insufficient arguments."
	end
	p_type = p_type:lower()
	if (p_type == "option") then
		local status, message = config_remove_option(...)
		if (status) then
			p_message:reply("The option was removed.")
		else
			p_message:reply("The option could not be removed.\nReason: " .. message)
		end
		return status, message
	elseif (p_type == "value") then
		local status, message = config_remove_value(...)
		if (status) then
			p_message:reply("The value was removed.")
		else
			p_message:reply("The value could not be removed.\nReason: " .. message)
		end
		return status, message
	end
	p_message:reply("Nothing was removed.\nReason: Unknown type.")
	return false, "Unknown type."
end

local function config_wrapper(p_message, p_action, ...)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	if (not p_action) then
		p_message:reply("Insufficient arguments.")
	end
	if (p_action == "restore") then
		local status, message = config.read(global.config_path)
		if (status) then
			p_message:reply("The configuration was restored.")
		else
			p_message:reply("The configuration could not be restored.\nReason: " .. message)
		end
		return status, message
	elseif (p_action == "save") then
		local status, message = config.write(global.config_path)
		if (status) then
			p_message:reply("The configuration was saved.")
		else
			p_message:reply("The configuration could not be saved.\nReason: " .. message)
		end
		return status, message
	elseif (p_action == "add") then
		return config_add(p_message, ...)
	elseif (p_action == "remove") then
		return config_remove(p_message, ...)
	end
end

local function wait_wrapper(p_message, p_mod, p_game_type, p_timeout)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local status, message = matchmaker.add_waiting(p_message.author, p_mod, p_game_type, tonumber(p_timeout))
	if (status) then
		p_message:reply("You have been added to the match waiting list.")
	else
		p_message:reply("You could not be added to the match waiting list.\nReason: " .. message)
	end
	return status, message
end

local function play_wrapper(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local status, message = matchmaker.remove_waiting(p_message.author)
	if (status) then
		p_message:reply("You have been removed from the match waiting list")
	else
		p_message:reply("You could not be remove from the match waiting list.\nReason: " .. message)
	end
	return status, message
end

local function list_wrapper(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	p_message:reply("```" .. matchmaker.to_string() .. "```")
	return true
end

local function announce_wrapper(p_message, p_mod, p_game_type, p_description)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local status, message = matchmaker.announce(p_message.author, p_mod, p_game_type, p_description)
	if (status) then
		p_message:reply("Your game has been announced.")
	else
		p_message:reply("Your game could not be announced.\nReason: " .. message)
	end
	return status, message
end

local function mods(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	print(config.options["MODS"])
	local source = config.options["MODS"] or default.options["MODS"]
	p_message:reply("Known mods: " .. table.concat(source, ", "))
	return true
end

local function game_types(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local source = config.options["GAME_TYPES"] or default.options["GAME_TYPES"]
	p_message:reply("Known game types: " .. table.concat(source, ", "))
	return true
end

--	Init Code

config.read(global.config_path)
command.add("about", about)
command.add("help", help)
command.add("quit", quit, true)
command.add("config", config_wrapper, true)
command.add("wait", wait_wrapper)
command.add("play", play_wrapper)
command.add("list", list_wrapper)
command.add("announce", announce_wrapper)
command.add("mods", mods)
command.add("game_types", game_types)
global.client:run(args[2])
