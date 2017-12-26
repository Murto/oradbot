local utility = require("./utility")


local activity = {}

activity.event_types = {
		"ready",
		"shardReady",
		"shardResumed",
		"channelCreate",
		"channelUpdate",
		"channelDelete",
		"recipientAdd",
		"recipientRemove",
		"guildAvailable",
		"guildCreate",
		"guildUpdate",
		"guildUnavailable",
		"guildDelete",
		"userBan",
		"userUnban",
		"emojisUpdate",
		"memberJoin",
		"memberLeave",
		"memberUpdate",
		"roleCreate",
		"roleUpdate",
		"roleDelete",
		"messageCreate",
		"messageUpdateUncached",
		"messageDelete",
		"messageDeleteUncached",
		"reactionAdd",
		"reactionAddUncached",
		"reactionRemove",
		"reactionRemoveUncached",
		"pinsUpdate",
		"presenceUpdate",
		"relationshipUpdate",
		"relationshipAdd",
		"relationshipRemove",
		"typingStart",
		"userUpdate",
		"voiceConnect",
		"voiceDisconnect",
		"voiceUpdate",
		"voiceChannelJoin",
		"voiceChannelLeave",
		"voiceChannelUpdate",
		"webhooksUpdate",
		"debug",
		"info",
		"warning",
		"error",
		"heartbeat",
		"raw"
	}

function activity:new(func, triggers, enabled)
	assert(func, "func cannot be nil")
	assert(triggers, "triggers cannot be nil")
	assert(#triggers, "triggers cannot be empty")
	enabled = (enabled == nil and true) or enabled
	local a = {}
	setmetatable(a, self)
	self.__index = self
	a.func = func
	a.triggers = triggers
	a.enabled = enabled
	return a
end

function activity:run(params)
	params = params or {}
	self.func(unpack(params))
end

function activity:has_trigger(trigger)
	assert(trigger, "trigger cannot be nil")
	return utility.contains(self.triggers, trigger)
end

function activity:is_enabled()
	return self.enabled
end

return activity
