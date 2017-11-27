--	Required files

local config = require("config")
local command = require("command")
local default = require("default")
local discordia = require("discordia")
local global = require("global")
local matchmaker = require("matchmaker")
local message_handler = require("message_handler")
local utility = require("utility")


--	Bot stuff

global.client = discordia.Client()
global.client.cacheAllMembers = false

global.client:on("ready", function()
	utility.colourful_print("[*] Connected.", 32)
end)

local function split_command(p_str)
	local strs = {}
	for str in p_str:gmatch("%S+") do
		table.insert(strs, str)
	end
	return strs
end

local function handle_message(p_message)
	local name, args = command.parse(p_message.content)
	if (name) then
		local status, message = command.execute(p_message, name, args)
		if (status) then
			utility.colourful_print("[*] " .. name .. " : " .. (message or "Success."), 32)
		else
			utility.colourful_print("[!] " .. name .. " : " .. (message or "Failure."), 33)
		end
	end
end

global.client:on("messageCreate", function(p_message)
	local status = pcall(function() handle_message(p_message) end)
	if (not status) then
		local msg = "Unexpected error."
		utility.colourful_print("[!] " .. msg, 33)
		message_handler.reply(p_message, message_handler.make_embed(msg, 0xFF0000))
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
		message_handler.reply(p_message, message_handler.make_embed("The about file could not be read.", 0xFF0000))
		return false, "Could not open file."
	end
	message_handler.reply(p_message, message_handler.make_embed(file:read("*all"), 0x00BB00))
	file:close()
	return true
end

local function help(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local file = io.open(global.help_path, "r")
	if (not file) then
		message_handler.reply(p_message, message_handler.make_embed("The help file could not be read", 0xFF0000))
		return false, "Could not open file"
	end
	message_handler.reply(p_message, message_handler.make_embed(file:read("*all"), 0x00BB00))
	file:close()
	return true
end

local function quit(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	message_handler.reply(p_message, message_handler.make_embed("See you next time...", 0x00BB00))
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
			message_handler.reply(p_message, message_handler.make_embed("The option was added.", 0x00BB00))
		else
			message_handler.reply(p_message, message_handler.make_embed("The option could not be added.\nReason: " .. message, 0xFF0000))
		end
		return status, message
	elseif (p_type == "value") then
		local status, message = config_add_value(...)
		if (status) then
			message_handler.reply(p_message, message_handler.make_embed("The value was added.", 0x00BB00))
		else
			message_handler.reply(p_message, message_handler.make_embed("The value could not be added.\nReason: " .. message, 0xFF0000))
		end
		return status, message
	end
	message_handler.reply(p_message, message_handler.make_embed("Nothing was added.\nReason: Unknown type.", 0xFF0000))
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
			message_handler.reply(p_message, message_handler.make_embed("The option was removed.", 0x00BB00))
		else
			message_handler.reply(p_message, message_handler.make_embed("The option could not be removed.\nReason: " .. message, 0xFF0000))
		end
		return status, message
	elseif (p_type == "value") then
		local status, message = config_remove_value(...)
		if (status) then
			message_handler.reply(p_message, message_handler.make_embed("The value was removed.", 0x00BB00))
		else
			message_handler.reply(p_message, message_handler.make_embed("The value could not be removed.\nReason: " .. message, 0xFF0000))
		end
		return status, message
	end
	message_handler.reply(p_message, message_handler.make_embed("Nothing was removed.\nReason: Unknown type.", 0xFF0000))
	return false, "Unknown type."
end

local function config_wrapper(p_message, p_action, ...)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	if (not p_action) then
		message_handler.reply(p_message, message_handler.make_embed("Insufficient arguments.", 0xFF0000))
	end
	if (p_action == "restore") then
		local status, message = config.read(global.config_path)
		if (status) then
			message_handler.reply(p_message, message_handler.make_embed("The configuration was restored.", 0x00BB00))
		else
			message_handler.reply(p_message, message_handler.make_embed("The configuration could not be restored.\nReason: " .. message, 0xFF0000))
		end
		return status, message
	elseif (p_action == "save") then
		local status, message = config.write(global.config_path)
		if (status) then
			message_handler.reply(p_message, message_handler.make_embed("The configuration was saved.", 0x00BB00))
		else
			message_handler.reply(p_message, message_handler.make_embed("The configuration could not be saved.\nReason: " .. message, 0xFF0000))
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
		message_handler.reply(p_message, message_handler.make_embed("You have been added to the match waiting list.", 0x00BB00))
	else
		message_handler.reply(p_message, message_handler.make_embed("You could not be added to the match waiting list.\nReason: " .. message, 0xFF0000))
	end
	return status, message
end

local function play_wrapper(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local status, message = matchmaker.remove_waiting(p_message.author)
	if (status) then
		message_handler.reply(p_message, message_handler.make_embed("You have been removed from the match waiting list", 0x00BB00))
	else
		message_handler.reply(p_message, message_handler.make_embed("You could not be removed from the match waiting list.\nReason: " .. message, 0xFF0000))
	end
	return status, message
end

local function list_wrapper(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	message_handler.reply(p_message, message_handler.make_embed(matchmaker.to_string(), 0x00BB00))
	return true
end

local function announce_wrapper(p_message, p_mod, p_game_type, p_description)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local status, message = matchmaker.announce(p_message.author, p_mod, p_game_type, p_description)
	if (status) then
		message_handler.reply(p_message, message_handler.make_embed("Your game has been announced.", 0x00BB00))
	else
		message_handler.reply(p_message, message_handler.make_embed("Your game could not be announced.\nReason: " .. message, 0xFF0000))
	end
	return status, message
end

local function mods(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local source = config.options["MODS"] or default.options["MODS"]
	message_handler.reply(p_message, message_handler.make_embed("**Known Mods**\n" .. table.concat(source, ", "), 0x00BB00))
	return true
end

local function game_types(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local source = config.options["GAME_TYPES"] or default.options["GAME_TYPES"]
	message_handler.reply(p_message, message_handler.make_embed("**Known game types**\n" .. table.concat(source, ", ")))
	return true
end

local function get_role(p_guild, p_name)
	if (not (p_guild and p_name)) then
		return false, "Insufficient arguments."
	end
	for role in p_guild.roles do
		if (role.name:lower() == p_name) then
			return role
		end
	end
	return false, "No such role."
end

local function role(p_message, p_role)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	if (not p_message.member) then
		return false, "Private channel."
	end
	if (not p_role) then
		message_handler.reply(p_message, message_handler.make_embed("Role must be specified.", 0xFF00))
		return false, "Insufficient arguments."
	end
	p_role = p_role:lower()
	local source = config.options["ROLES"] or default.options["ROLES"]
	if (utility.contains(source, p_role)) then
		local role = get_role(p_message.guild, p_role)
		if (role) then
			if (not get_role(p_message.member, p_role)) then
				p_message.member:addRole(role)
				message_handler.reply(p_message, message_handler.make_embed("You have been added to " .. p_role .. ".", 0x00BB00))
				return true
			else
				p_message.member:removeRole(role)
				message_handler.reply(p_message, message_handler.make_embed("You have been removed from " .. p_role .. ".", 0x00BB00))
				return true
			end
		end
	end
	local message = "Unknown role."
	message_handler.reply(p_message, message_handler.make_embed("You could not be added/removed from " .. p_role .. ".\nReason: " .. message, 0xFF00))
	return false, message
end

local function roles(p_message)
	if (not p_message) then
		return false, "Insufficient arguments."
	end
	local source = config.options["ROLES"] or default.options["ROLES"]
	message_handler.reply(p_message, message_handler.make_embed("**Known roles**\n" .. table.concat(source, ", ")))
	return true
end

local function ping(p_message)
	p_message:reply({embed={description="pong",color=0x00BB00}})
	return true
end

local function throw()
	error("Throwing error")
end

--	Init Code

config.read(global.config_path)
command.add("ping", ping)
command.add("throw", throw, true)
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
command.add("role", role)
command.add("roles", roles)

local status = false

-- Run the client forever
while (not status) do
	status = pcall(global.client:run("Bot " .. args[2]))
end
