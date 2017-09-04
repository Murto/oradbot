local command = require("command")
local config = require("config")
local default = require("default")
local utility = require("utility")

local matchmaker = {}
matchmaker.waiting = {}


--	Matchmaker functions

local function valid_mod(p_mod)
	if (not p_mod) then
		return false, "Insufficient arguments."
	end
	if (config.options["MODS"]) then
		return utility.contains(config.options["MODS"], p_mod)
	end
	return utility.contains(default.options["MODS"], p_mod)
end

local function valid_game_type(p_game_type)
	if (not p_game_type) then
		return false, "Insufficient arguments."
	end
	if (config.options["GAME_TYPES"]) then
		return utility.contains(config.options["GAME_TYPES"], p_game_type)
	end
	return utility.contains(default.options["GAME_TYPES"], p_game_type)
end

function matchmaker.add_waiting(p_user, p_mod, p_game_type, p_timeout)
	if (not (p_user and p_mod and p_game_type)) then
		return false, "Insufficient arguments."
	end
	p_mod = p_mod:lower()
	p_game_type = p_game_type:lower()
	if (not (p_mod == "any" or valid_mod(p_mod))) then
		return false, "Unknown mod."
	end
	if (not (p_game_type == "any" or valid_game_type(p_game_type))) then
		return false, "Unknown game type."
	end
	if (p_timeout) then
		p_timeout = os.time() + (p_timeout * 60)
	end
	matchmaker.waiting[p_user] = {mod = p_mod, game_type = p_game_type, timeout = p_timeout}
	return true
end

function matchmaker.remove_waiting(p_user)
	if (not p_user) then
		return false, "Insufficient arguments."
	end
	if (not matchmaker.waiting[p_user]) then
		return false, "Player is not waiting."
	end
	matchmaker.waiting[p_user] = nil
	return true
end

function matchmaker.announce(p_user, p_mod, p_game_type, p_description)
	matchmaker.remove_timedout()
	if (not (p_user and p_mod and p_game_type)) then
		return false, "Insufficient arguments."
	end
	p_mod = p_mod:lower()
	p_game_type = p_game_type:lower()
	if (not valid_mod(p_mod)) then
		return false, "Unknown mod."
	end
	if (not valid_game_type(p_game_type)) then
		return false, "Unknown game type."
	end
	for user, info in pairs(matchmaker.waiting) do
		if (p_mod == info.mod and p_game_type == info.game_type and p_user ~= user) then
			user:sendMessage(p_user.username .. " has announced a " .. p_mod .. " " .. p_game_type .. "!" .. ((p_description and "\nDescription: " .. p_description) or ""))
		end
	end
	return true
end

local function timedout(p_user)
	if (not p_user) then
		return false, "Insufficient arguments."
	end
	if (not matchmaker.waiting[p_user]) then
		return false, "Player is not waiting."
	end
	if (not matchmaker.waiting[p_user].timeout) then
		return false, "Player does not have a timeout."
	end
	return os.time() >= matchmaker.waiting[p_user].timeout
end

function matchmaker.remove_timedout()
	for user, info in pairs(matchmaker.waiting) do
		if (timedout(user)) then
			matchmaker.remove_waiting(user)
			user:sendMessage("You timed out and have been removed from the game waiting list.")
		end
	end
end

function matchmaker.to_string()
	matchmaker.remove_timedout()
	local str = "|      PLAYER      |  MOD  | GAME TYPE | TIMEOUT |\n|>----------------<|>-----<|>---------<|>-------<|\n"
	for user, info in pairs(matchmaker.waiting) do
		str = str
			.. "| "
			.. utility.left_padded_field(user.username, 16)
			.. " | "
			.. utility.left_padded_field(info.mod, 5)
			.. " | "
			.. utility.left_padded_field(info.game_type, 9)
			.. " | "
			.. ((info.timeout and utility.right_padded_field(tostring(math.floor((info.timeout - os.time()) / 60)), 7)) or "       ")
			.. " |\n"
	end
	return str .. "|>----------------<|>-----<|>---------<|>-------<|"
end


return matchmaker
