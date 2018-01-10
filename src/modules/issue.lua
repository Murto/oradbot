local activity = require("../activity")
local command = require("../command")
local embed = require("../embed")
local module = require("../module")

local http = require("coro-http")
local json = require("json")

local github = "https://api.github.com/repos/OpenRA/OpenRA/issues/"

function post_issues(msg, numbers, eflag)
  coroutine.wrap(function()
    for _, number in ipairs(numbers) do
      print(number)
      local _, content = http.request("GET", github .. number, {{"User-Agent", "oradbot"}})
      local info = json.parse(content)
      if (info) then
        if (info.message) then
          if (eflag) then
            if (info.message:match("API rate limit")) then
              msg:reply(embed:new("**Error:**\n\tAPI rate limit exceeded", 0xBB0000))
            else
              msg:reply(embed:new("**Error:**\n\t" .. info.message, 0xBB0000))
            end
          end
        else
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
        end
      elseif (eflag) then
          msg:reply(embed:new("**Error:**\n\tGithub API failure", 0xBB0000))
      end
    end
  end)()
end

local issue = command:new("issue", function(msg, number)
    post_issues(msg, {number}, true)
  end, 0)


local interceptor = activity:new(function(msg)
    local numbers = {}
    for number in msg.content:gmatch("^#(%d+)%s") do
      print(number)
      table.insert(numbers, number)
    end
    for number in msg.content:gmatch("%s#(%d+)%s") do
      print(number)
      table.insert(numbers, number)
    end
    for number in msg.content:gmatch("%s#(%d+)$") do
      print(number)
      table.insert(numbers, number)
    end
    for number in msg.content:gmatch("^#(%d+)$") do
      print(number)
      table.insert(numbers, number)
    end
    post_issues(msg, numbers, false) 
  end, {"messageCreate", "messageUpdate"}, true)

local name = "Issue"
local desc = "Links issues for users"

return module:new(name, desc, {issue}, {interceptor})
