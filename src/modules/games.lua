local command = require("../command")
local embed = require("../embed")
local module = require("../module")
require("../strex")

local http = require("coro-http")
local json = require("json")


local master = "http://master.openra.net/games?type=json"


local function get_servers()
end

local games = command:new("games", function(msg)
    coroutine.wrap(function()
        local _, content = http.request("GET", master)
        local servers = json.parse(content)
        if (servers) then
          local sstr = ""
          for _, server in ipairs(servers) do
            local name = server.name
            local players = tonumber(server.players)
            local max_players = tonumber(server.maxplayers)
            local mod = server.mods
            local state = tonumber(server.state)
            if (players > 0 and state == 1) then
              sstr = sstr .. "@ " .. name .. "\n  " .. tostring(players) .. "/" .. tostring(max_players) .. " players\n  " .. mod .. "\n\n"
            end
          end
          if (#sstr > 0) then
            msg:reply("```" .. sstr .. "```")
          else
            msg:reply(embed:new("No games available", 0x00BB00))
          end
        else
          msg:reply(embed:new("**Error:**\n\tMaster server contact failed", 0xBB0000))
        end
      end)()
  end, 0)


local name = "Games"
local desc = "Displays the current OpenRA games"


return module:new(name, desc, {games}, nil)
