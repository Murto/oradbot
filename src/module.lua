local command = require("command")

local module = {}

function module:new(name, desc, commands, activites)
	assert(name, "Name cannot be nil")
	local m = {}
	setmetatable(m, self)
	self.__index = self
	m.name = name
	m.desc = desc or "No description available"
	m.commands = {}
	for _, c in ipairs(commands) do
		m.commands[c:get_name()] = c
	end
	m.activities = activites or {}
	return m
end

function module:get_command(name)
	assert(name, "name cannot be nil")
	return self.commands[name]
end

function module:get_activites(trigger)
	assert(trigger, "trigger cannot be nil")
	local as = {}
	for _, a in ipairs(self.activities) do
		if (a.has_trigger(trigger)) then
			table.insert(as, a)
		end
	end
	return as
end

return module
