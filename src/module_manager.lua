local embed = require("embed")
local global = require("global")

local module_manager = {}

local function load_error_handler(name)
	assert(name, "name cannot be nil")
	return function(msg)
			assert(msg, "msg cannot be nil")
			local str = "Module \"" .. name .. "\" could  not be loaded, reason: " .. msg
			print(str)
			global.logger:log_warning(str)
		end
end

function module_manager:new(dir, config)
	assert(dir, "dir cannot be nil")
	local m = {}
	setmetatable(m, self)
	self.__index = self
	m.dir = dir
	m.mods = {}
	m.levels = {}
	if (config) then
		local section = config:get_section("PERMISSIONS")
		if (section) then
			local values = section:get_property("LEVELS")
			if (values) then
				for _, v in ipairs(values) do
					local name = v:match("(%S+#%d%d%d%d):")
					local level = v:match(":(%d+)")
					m.levels[name] = level
				end
			end
		end
	end
	return m
end

function module_manager:load(name)
	assert(name, "name cannot be nil")
	local load_func, reason = loadfile(self.dir .. "/" .. name .. ".lua")
	if (not load_func) then
		error(reason)
	end
	local module = load_func()
	self.mods[name] = module
	return true
end

function module_manager:load_all(names)
	assert(names, "names cannot be nil")
	for _, name in ipairs(names) do
		xpcall(function() self:load(name) end, load_error_handler(name))
	end
end

function module_manager:unload(name)
	assert(name, "name cannot be nil")
	self.mods[name] = nil
	return true
end

function module_manager:unload_all(names)
	names = names or utility.keys(self.mods)
	for _, name in ipairs(names) do
		self:unload(name)
	end
end

function module_manager:reload_all()
	for _, name in ipairs(utility.keys(self.mods)) do
		xpcall(function() self:load(name) end, load_error_handler(name))
	end
end

function module_manager:run_command(name, msg, params)
	assert(name, "name cannot be nil")
	assert(msg, "msg cannot be nil")
	params = params or {}
	for _, m in pairs(self.mods) do
		local c = m:get_command(name)
		if (c) then
			local level = c:get_level()
			if ((self.levels[msg.fullname] or 0) >= level) then
				c:run(msg, params)
			else
				msg:reply(embed:new("Insufficient permissions", 0xBB0000))
			end
			return
		end
	end
	msg:reply(embed:new("Unknown command", 0xBB0000))
end

function module_manager:run_activities(trigger, params)
	assert(trigger, "trigger cannot be nil")
	params = params or {}
	for _, m in pairs(self.mods) do
		local activites = m:get_activites(trigger)
		for _, a in ipairs(activites) do
			a:run(unpack(params))
		end
	end
end

return module_manager
