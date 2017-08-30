local matchmaker = {}
matchmaker.waiting = {}
matchmaker.mod_types = {}
matchmaker.game_types = {}

function matchmaker.add_mod_type(p_mod_type)
	if (not p_mod_type) then
		return false, "mod_type must be given."
	elseif (p_mod_type == "any") then
		return false, "\"any\" is reserved."
	elseif (matchmaker.mod_types[p_mod_type]) then
		return false, "Already a mod_type."
	end
	matchmaker.mod_types[p_mod_type] = true
	return true
end

function matchmaker.remove_mod_type(p_mod_type)
	if (not p_mod_type) then
		return false, "mod_type must be given."
	elseif (not matchmaker.mod_types[p_mod_type]) then
		return false, "Not a mod_type."
	end
	matchmaker.mod_types[p_mod_type] = nil
	return true
end

function matchmaker.add_game_type(p_game_type)
	if (not p_game_type) then
		return false, "game_type must be given."
	elseif (p_game_type == "any") then
		return false, "\"any\" is reserved."
	elseif (matchmaker.game_types[p_game_type]) then
		return false, "Already a game_type."
	else
		matchmaker.game_types[p_game_type] = true
		return true
	end
end

function matchmaker.remove_game_type(p_game_type)
	if (not p_game_type) then
		return false, "game_type must be given."
	elseif (not matchmaker.game_types[p_game_type]) then
		return false, "Not a game_type."
	end
	matchmaker.game_types[p_game_type] = nil
	return true
end

function matchmaker.add_waiting(p_user, p_mod_type, p_game_type, p_timeout)
	if (not matchmaker.mod_types[p_mod_type] and p_mod_type ~= "any") then
		return false, "Unknown mod type."
	end
	if (not matchmaker.game_types[p_game_type] and p_game_type ~= "any") then
		print("game type: \"" .. p_game_type .. "\"")
		return false, "Unknown game type."
	end
	if (p_timeout) then
		if (p_timeout <= 0) then
			return false, "Timeout is too short."
		elseif (p_timeout > 9999999) then
			return false, "Timeout is too long."
		else
			p_timeout = (p_timeout * 60) + os.time()
		end
	end
	matchmaker.waiting[p_user] = {mod_type = p_mod_type, game_type = p_game_type, timeout = p_timeout}
	return true
end

function matchmaker.remove_waiting(p_user)
	if (matchmaker.waiting[p_user]) then
		matchmaker.waiting[p_user] = nil
		return true
	end
	return false, "User is not on waiting list."
end

local function timedout(p_user)
	if (not matchmaker.waiting[p_user]) then
		return false, "User is not on waiting list."
	elseif (not matchmaker.waiting[p_user].timeout) then
		return false, "User cannot time out."
	end
	return matchmaker.waiting[p_user].timeout < os.time()
end

function matchmaker.remove_timeouts()
	for user, _ in pairs(matchmaker.waiting) do
		if (timedout(user)) then
			matchmaker.remove_waiting(user)
			user:sendMessage("You timed out and have been removed from the match waiting list.")
		end
	end
end

function matchmaker.announce(p_user, p_mod_type, p_game_type)
	matchmaker.remove_timeouts()
	if (not matchmaker.mod_types[p_mod_type]) then
		return false, "Unknown mod type."
	end
	if (not matchmaker.game_types[p_game_type] or p_game_type == "any") then
		return false, "Unknown game type."
	end
	local msg = p_user.username .. " has announced a " .. p_game_type .. " game!"
	for user, info in pairs(matchmaker.waiting) do
		if ((info.mod_type == "any" or info.mod_type == p_mod_type) and (info.game_type == "any" or info.game_type == p_game_type) and p_user ~= user) then
			user:sendMessage(msg)
		end
	end
	return true
end

local function left_padded_field(p_field, p_size)
	local str = p_field:sub(1, p_size)
	return str .. string.rep(" ", p_size - str:len())
end

local function right_padded_field(p_field, p_size)
	local str = p_field:sub(1, p_size)
	return string.rep(" ", p_size - str.len()) .. str
end

function matchmaker.to_string()
	matchmaker.remove_timeouts()
	local str = "```|      PLAYER      | MOD TYPE | GAME TYPE | TIMEOUT |\n| ---------------- | -------- | --------- | ------- |\n"
	for user, info in pairs(matchmaker.waiting) do
		str = str
			.. "| "
			.. left_padded_field(user.username, 16)
			.. " | "
			.. left_padded_field(info.mod_type, 8)
			.. " | "
			.. left_padded_field(info.game_type, 9)
			.. " | "
			.. (function()
				if (info.timeout) then
					return right_padded_field(tostring(math.floor((info.timeout - os.time()) / 60)), 7)
				end
				return "       "
			end)()
			.. " |\n"
	end
	str = str .. "| ---------------- | -------- | --------- | ------- |```"
	return str
end

return matchmaker
