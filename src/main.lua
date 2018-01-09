local activity = require("./activity")
local configuration = require("./configuration")
local embed = require("./embed")
local global = require("./global")
local logger = require("./logger")
local module_manager = require("./module_manager")

local discordia = require("discordia")

-- Error handlers

local function fatal_error_handler(msg)
  print("Fatal: " .. msg)
  global.log:log_error("Fatal: " .. msg)
  os.exit()
end


-- Init functions

local function init_config()
  local config = configuration:new("oradbot.conf")
  global.log:log_success("Configuration intialised")

  config:read()
  global.log:log_success("Configuration read")

  global.config = config
  global.log:log_success("Configuration globalised")
end

local function init_modules()
  local section = assert(global.config:get_section("MODULES"), "Incomplete configuration")
  local files = assert(section:get_property("FILES"), "Incomplete configuration")
  local dirs = assert(section:get_property("DIRS"), "Incomplete configuration")[1]
  local mod_man = module_manager:new(dirs, global.config)
  global.mod_man = mod_man
  mod_man:load_all(files)
end

local function handle_command(msg)
  assert(msg, "msg cannot be nil")
  local name = msg.content:match("^!(%S+)")
  local params = {}
  for param in msg.content:gmatch("%s+(%S+)") do
    table.insert(params, param)
  end
  local status, reason = pcall(function() global.mod_man:run_command(name, msg, params) end)
  if (not status) then
    msg:reply(embed:new("**Error**:\n\t" .. reason:match(":([^:]+)$"), 0xBB0000))
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
    handle_activity("messageCreate", {msg})
  end)

global.client:on("messageUpdate", function(msg)
    if (msg.content:match("^!")) then
      global.log:log_message("Command detected: " .. msg.content)
      handle_command(msg)
    end
    handle_activity("messageUpdate", {msg})
  end)

global.client:run("Bot " .. args[2])
