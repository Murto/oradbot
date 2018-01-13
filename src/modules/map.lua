local command = require("../command")
local embed = require("../embed")
local module = require("../module")

local http = require("coro-http")
local json = require("json")

local resources = "https://resource.openra.net/map/title/"

local map = command:new("map", function(msg, ...)
    assert(..., "A map name must be provided")
    local map_pattern = table.concat({...}, "%20")
    coroutine.wrap(function()
         local _, content = http.request("GET", resources .. map_pattern)
         local maps = json.parse(content)
         if (maps) then
           for _, map in ipairs(maps) do
             if (map.last_revision) then
               local title = map.title
               if (map.advanced_map) then
                 title = title .. " [Advanced]"
               end
               if (map.lua) then
                 title = title .. " [Lua]"
               end
               local desc = map.info:match("[^\n]*\n") or "No description."
               local e = {}
               e.embed = {}
               e.embed.color = 0x00BB00
               e.embed.title = title
               e.embed.description = desc
               e.embed.author = {}
               e.embed.author.name = map.author
               e.embed.author.icon_url = "https://resource.openra.net/static/images/soviet-logo.svg"
               e.embed.url = map.url:match("(.*)/oramap")
               msg:reply(e)
               return
             end
           end
         end
         msg:reply(embed:new("**Error:**\n\tMap not found.", 0xBB0000))
      end)()
  end, 0)

local name = "Map"
local desc = "Displays information of map with the given name"

return module:new(name, desc, {map}, nil)
