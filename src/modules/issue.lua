local activity = require("../activity")
local command = require("../command")
local embed = require("../embed")
local module = require("../module")

local http = require("coro-http")
local json = require("json")

local github = "https://api.github.com/repos/OpenRA/OpenRA/issues/"

local issue = command:new("issue", function(msg, number)
    assert(number, "A number must be provided")
    number = tonumber(number)
    assert(number, "Invalid number")
    coroutine.wrap(function()
      local _, content = http.request("GET", github .. number, {{"User-Agent", "oradbot"}})
      local info = json.parse(content)
      if (not info) then
        msg:reply(embed:new("**Error:**\n\tGithub API failure", 0xBB0000))
        return
      end
      if (info.message) then
        msg:reply(embed:new("**Error:**\n\t" .. info.message, 0xBB0000))
        return
      end
      local e = {}
      e.embed = {}
      e.embed.color = 0x00BB00
      e.embed.author = {}
      e.embed.author.name = info.user.login
      e.embed.author.icon_url = info.user.avatar_url
      e.embed.title = "**#" .. number .. " | " .. info.title .. " (" .. info.state .. ")**"
      e.embed.url = info.html_url
      e.embed.description = ((#info.body > 0) and info.body) or "No description given."
      msg:reply(e)
    end)()
  end, 0)

local interceptor = activity:new(function(msg)
    local number = msg.content:match("#(%d+)%s") or msg.content:match("#(%d+)$")
    if (number) then
      coroutine.wrap(function()
        local _, content = http.request("GET", github .. number, {{"User-Agent", "oradbot"}})
        local info = json.parse(content)
        if (not info) then
          return
        end
        if (info.message) then
          return
        end
        local e = {}
        e.embed = {}
        e.embed.color = 0x00BB00
        e.embed.author = {}
        e.embed.author.name = info.user.login
        e.embed.author.icon_url = info.user.avatar_url
        e.embed.title = "**#" .. number .. " | " .. info.title .. " (" .. info.state .. ")**"
        e.embed.url = info.html_url
        e.embed.description = ((#info.body > 0) and info.body) or "No description given."
        msg:reply(e)
      end)()
    end
  end, {"messageCreate", "messageUpdate"}, true)

local name = "Issue"
local desc = "Links issues for users"

return module:new(name, desc, {issue}, {interceptor})
