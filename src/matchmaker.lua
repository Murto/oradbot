local matchmaker = {}
local waiting = {}
local game_types = {
		["1v1"]			= true,
		["team"]		= true,
		["mini"]		= true,
		["any"]			= true
	}

function matchmaker.add_waiting(p_user, p_game_type, p_timeout)
	if (not game_types[p_game_type]) then
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
	waiting[p_user] = {game_type = p_game_type, timeout = p_timeout}
	return true
end

function matchmaker.remove_waiting(p_user)
	if (waiting[p_user]) then
		waiting[p_user] = nil
		return true
	end
	return false, "User is not on waiting list."
end

local function timedout(p_user)
	if (not waiting[p_user]) then
		return false, "User is not on waiting list."
	elseif (not waiting[p_user].timeout) then
		return false, "User cannot time out."
	end
	return waiting[p_user].timeout < os.time()
end

function matchmaker.remove_timeouts()
	for user, _ in pairs(waiting) do
		if (timedout(user)) then
			matchmaker.remove_waiting(user)
			user:sendMessage("You timed out and have been removed from the match waiting list.")
		end
	end
end

function matchmaker.announce(p_user, p_game_type)
	matchmaker.remove_timeouts()
	if (not game_types[p_game_type] or p_game_type == "any") then
		return false, "Unknown game type."
	end
	local msg = p_user.username .. " has announced a " .. p_game_type .. " game!"
	for user, info in pairs(waiting) do
		if ((info.game_type == "any" or info.game_type == p_game_type) and p_user ~= user) then
			user:sendMessage(msg)
		end
	end
	return true
end

function matchmaker.to_string()
	matchmaker.remove_timeouts()
	local str = "```|              PLAYER              | GAME TYPE | TIMEOUT |\n| -------------------------------- | --------- | ------- |\n"
	for user, info in pairs(waiting) do
		str = str
			.. "| "
			.. user.username
			.. string.rep(" ", 33 - user.username:len())
			.. "| "
			.. info.game_type
			.. string.rep(" ", 10 - info.game_type:len())
			.. "| "
			.. (function()
				local str = nil
				if (info.timeout) then
					str = tostring(math.floor((info.timeout - os.time()) / 60))
					str = string.rep(" ", 7 - str:len()) .. str
				else
					str = "       "
				end
				return str
			end)()
			.. " |\n"
	end
	str = str .. "| -------------------------------- | --------- | ------- |```"
	return str
end

return matchmaker
