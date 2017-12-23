local activity = require("activity")
local configuration = require("configuration")
local defaults = require("defaults")
local discordia = require("discordia")
local embed = require("embed")
local global = require("global")
local logger = require("logger")
local module_manager = require("module_manager")


-- Error handlers

local function fatal_error_handler(msg)
	print("Fatal: " .. msg)
	global.log:log_error("Fatal: " .. msg)
	os.exit()
end


-- Init functions

local function init_config()
	local config = configuration:new(defaults.config_path)
	global.log:log_success("Configuration intialised")

	config:read()
	global.log:log_success("Configuration read")

	global.config = config
	global.log:log_success("Configuration globalised")
end

local function init_modules()
	local section = global.config:get_section("MODULES")
	if (not section) then
		return
	end
	
	local prop = section:get_property("FILES")
	if (not prop) then
		return
	end
	local files = prop:get_values()

	local dir = defaults.mod_dir
	prop = section:get_property("DIR")
	if (prop) then
		dir = prop:get_value(1) or dir
	end

	local mod_man = module_manager:new(dir, global.config)
	mod_man:load_all(files)
	global.mod_man = mod_man
end

local function handle_command(msg)
	assert(msg, "msg cannot be nil")
	local name = msg.content:match("^!(%S+)")
	local params = {}
	for param in msg.content:gmatch("%S+%s+(%S+)") do
		table.insert(params, param)
	end
	local status = pcall(function() global.mod_man:run_command(name, msg, params) end)
	if (not status) then
		msg:reply(embed:new("An unknown error occured", 0xBB0000))
	end
end

local function handle_activity(event, params)
	assert(event, "event cannot be nil")
	params = params or {}
	global.mod_man:run_activities(event, params)
end


-- Init

global.log = logger:new("bot.log")
local status = xpcall(init_config, fatal_error_handler)
status = xpcall(init_modules, fatal_error_handler)

global.client = discordia.Client()

-- Set up bot
for _, event in ipairs(activity.event_types) do
	global.client:on(event, function(a, b, c, d)
			handle_activity(event, {a, b, c, d})
		end)
end

global.client:on("messageCreate", function(msg)
		if (msg.content:match("^!%S+")) then
			global.log:log_message("Command detected: " .. msg.content)
			handle_command(msg)
		end
	end)

global.client:on("messageUpdate", function(msg)
		if (msg.content:match("^!")) then
			global.log:log_message("Command detected: " .. msg.content)
			handle_command(msg)
		end
	end)


global.client:run("Bot " .. args[2])
