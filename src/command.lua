local config = require("config")
local utility = require("utility")


local command = {}
command.commands = {}
command.token = '!'


--	Command functions

function command.__index(p_command, p_key)
	return p_command.commands[p_key]
end

function command.__newindex(p_command, p_key, p_value)
	p_command.commands[p_key] = value
end

function command.commands.__index()
	return false, "Unknown command."
end

function command.add(p_name, p_action, p_admin, p_force)
	if (not (p_name and p_action)) then
		return false, "Insufficient arguments."
	end
	if (command[p_name] and not p_force) then
		return false, "Command exists."
	end
	command[p_name] = {action = p_action, admin = p_admin}
	return true
end


function command.remove(p_name)
	if (not p_name) then
		return false, "Insufficient arguments."
	end
	if (not command[p_name]) then
		return false, "Unknown command."
	end
	command[p_name] = nil
	return true
end

local function split_string(p_str)
	if (not p_str) then
		return false, "Insufficient arguments."
	end
	local words = {}
	for word in p_str:gmatch("%S+") do
		table.insert(words, word)
	end
	return words
end

function command.parse(p_str)
	if (not p_str) then
		return false, "Insufficient arguments."
	end
	if (not p_str:match("^" .. command.token .. "%S+")) then
		return false, "Not a command."
	end
	local split = split_string(p_str:sub(2))
	local name = split[1]
	table.remove(split, 1)
	return name, split
end

function command.execute(p_message, p_name, p_args)
	if (not (p_message and p_name)) then
		return false, "Insufficient arguments."
	end
	if (not command[p_name]) then
		return false, "Unknown command"
	end
	if (command[p_name].admin and not utility.contains(config.options["ADMINS"], p_message.author.username)) then
		p_message:reply("Insufficient permissions.")
		return false, "Insufficient permissions."
	end
	p_args = p_args or {}
	return command[p_name].action(p_message, table.unpack(p_args))
end


return command
