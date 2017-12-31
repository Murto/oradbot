local activity = require("../activity")
local command = require("../command")
local embed = require("../embed")
local global = require("../global")
local module = require("../module")
local utility = require("../utility")
require("../strex")

-- Custom types

local expectant = {}

function expectant:new(member, mod_type, game_type, expires)
	assert(member, "member cannot be nil")
	assert(mod_type, "mod_type cannot be nil")
	assert(game_type, "game_type cannot be nil")
	assert(expires, "expires cannot be nil")
	local e = {}
	setmetatable(e, self)
	self.__index = self
	e.member = member
	e.mod_type = mod_type
	e.game_type = game_type
	e.expires = expires
	return e
end

function expectant:get_member()
	return self.member
end

function expectant:get_mod_type()
	return self.mod_type
end

function expectant:get_game_type()
	return self.game_type
end

function expectant:get_expiry()
	return self.expires
end

function expectant:has_expired()
	return os.time() >= self.expires
end


-- Configuration loading

assert(global.config,  "Missing configuration")
local section = assert(global.config:get_section("MATCHMAKING"), "Incomplete configuration")
local mod_types = assert(section:get_property("MOD_TYPES"), "Incomplete configuration")
local game_types = assert(section:get_property("GAME_TYPES"), "Incomplete configuration")
local max_timeout = tonumber(assert(section:get_property("MAX_TIMEOUT"), "Incomplete configuration")[1])


-- Module variables

local waiting = {}


-- Helper functions

local function valid_mod_type(mod_type)
	assert(mod_type, "mod_type cannot be nil")
	mod_type = mod_type:upper()
	for _, m in ipairs(mod_types) do
		if (mod_type == m:upper()) then
			return true
		end
	end
	return false
end

local function valid_game_type(game_type)
	assert(game_type, "game_type cannot be nil")
	game_type = game_type:upper()
	for _, g in ipairs(game_types) do
		if (game_type == g:upper()) then
			return true
		end
	end
	return false
end

local function remove_expired()
	for m, e in pairs(waiting) do
		if (e:has_expired()) then
			waiting[m] = nil
			m.user:send(embed:new("You have been removed from the match waiting list", 0xBBBB00))
		end
	end
end

local function wait(msg, mod_type, game_type, timeout)
		assert(msg.member, "This command cannot be used outside of a guild")
		assert(mod_type, "A mod type must be provided")
		assert(game_type, "A game type must be provided")
		assert(valid_mod_type(mod_type) or mod_type == "any", "Invalid mod type")
		assert(valid_game_type(game_type) or game_type == "any", "Invalid game type")
		timeout = tonumber(timeout) or max_timeout
		assert(timeout > 0, "Invalid timeout")
		assert(timeout <= max_timeout, "Timeout too great")
		remove_expired()
		local expires = os.time() + (timeout * 60)
		local e = expectant:new(msg.author, mod_type, game_type, expires)
		waiting[msg.member] = e
		msg:reply(embed:new("You have been added to the match waiting list", 0x00BB00))
	end

local function play(msg)
		assert(msg.member, "This command cannot be used outside of a guild")
		assert(waiting[msg.member], "You are not on the waiting list")
		remove_expired()
		waiting[msg.author] = nil
		msg:reply(embed:new("You have been removed from the match waiting list", 0x00BB00))
	end

local function announce(msg, mod_type, game_type, ...)
		assert(msg.member, "This command cannot be used outside of a guild")
		assert(mod_type, "A mod type must be provided")
		assert(game_type, "A game type must be provided")
		assert(valid_mod_type(mod_type), "Invalid mod type")
		assert(valid_game_type(game_type), "Invalid game type")
		remove_expired()
		local count = 0
		local str = "__**Game Ready**__\n\n**Mod Type**:\n\t" .. mod_type .. "\n\n**Game Type**:\n\t" .. game_type
		local trailing = {select(1, ...)}
		local desc = table.concat(trailing, " ")
		if (not (desc == "")) then
			str = str .. "\n\n**Desc**:\n\t" .. desc
		end
		for m, e in pairs(waiting) do
			if (not m.user == msg.author) then
				local m = e:get_mod_type()
				local g = e:get_game_type()
				if ((m == mod_type or m == "any") and (g == game_type or g == "any")) then
					count = count + 1
					m.user:send(embed:new(str, 0xBBBB00))
				end
			end
		end
		msg:reply(embed:new(count .. " players were notified", 0x00BB00))
	end

local function list(msg)
		assert(msg.member, "This command cannot be used outside of a guild")
		remove_expired()
		local str = ""
		for m, e in pairs(waiting) do
			str = str .. "@ " .. m.name:left_pad(30) .. " | " .. e:get_mod_type():left_pad(7) .. " | " .. e:get_game_type():left_pad(9) .. " | " .. tostring(math.ceil((e:get_expiry() - os.time()) / 60)) .. '\n'
		end
		if (str == "") then
			msg:reply(embed:new("Waiting is is empty", 0xBBBB00))
		else
			msg:reply("```\n" .. str .. "\n```")
		end
	end

local function mods(msg)
		msg:reply(embed:new("Mods: " .. table.concat(mod_types, ", "), 0x00BB00))
	end

local function games(msg)
		msg:reply(embed:new("Game types: " .. table.concat(game_types, ", "), 0x00BB00))
	end


-- Module commands

local match = command:new("match", function(msg, func, ...)
		assert(func, "No function provided")
		if (func == "wait") then
			wait(msg, ...)
		elseif (func == "play") then
			play(msg, ...)
		elseif (func == "announce") then
			announce(msg, ...)
		elseif (func == "list") then
			list(msg, ...)
		elseif (func == "games") then
			games(msg, ...)
		elseif (func == "mods") then
			mods(msg, ...)
		else
			error("Unknown function")
		end
	end, 0)

-- Module activites

local timeouts = activity:new(remove_expired, {"heartbeat"}, true)


-- Module creation

local name = "Matchmaking"
local desc = "Matchmaking service for the OpenRA discord server"

return module:new(name, desc, {match}, {timeouts})
