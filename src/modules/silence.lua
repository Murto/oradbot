local activity = require("../activity")
local command = require("../command")
local embed = require("../embed")
local global = require("../global")
local module = require("../module")

local silenced = {}

local function silence_channel(chan, duration)
	assert(chan, "chan cannot be nil")
	if (duration) then	
		silenced[chan] = os.time() + (duration * 60)
	else
		silenced[chan] = math.huge
	end
end

local function unsilence_channel(chan)
	assert(chan, "chan cannot be nil")
	assert(silenced[chan], "Channel is not silenced")
	silenced[chan] = nil
	chan:send(embed:new("This channel is no longer silenced", 0xBBBB00))
end

local function unsilence_expired()
	for chan, time in pairs(silenced) do
		if (os.time() >= time) then
			unsilence_channel(chan)
		end
	end
end


local delete_message = activity:new(function(msg)
		if (msg.author == global.client.user) then
			return
		end
		unsilence_expired()
		if (silenced[msg.channel] and global.mod_man:get_level(msg.author.fullname) < 50) then
			msg:delete()
		end
	end, {"messageCreate"}, false)

local timeouts = activity:new(function()
		unsilence_expired()
	end, {"heartbeat"}, false)


local silence = command:new("silence", function(msg, time)
		unsilence_expired()
		silence_channel(msg.channel, tonumber(time))
		delete_message:enable()
		timeouts:enable()
		msg:reply(embed:new("This channel is now silenced", 0x00BB00))
	end, 50)

local unsilence = command:new("unsilence", function(msg)
		unsilence_channel(msg.channel)
		unsilence_expired()
		if (not next(silenced)) then
			delete_message:disable()
			timeouts:disable()
		end
	end, 50)


local name = "Silence"
local desc = "Silences channels for some duration"

return module:new(name, desc, {silence, unsilence}, {delete_message, timeouts})
