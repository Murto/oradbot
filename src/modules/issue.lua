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
      local header, content = http.request("GET", github .. number, {{"User-Agent", "oradbot"}})
      local info = json.parse(content)
      if (info) then
        if (info.message) then
          if (eflag) then
            if (info.message:match("API rate limit")) then
              local delay = (os.time() - tonumber(header[8][2])) / 60
              msg:reply(embed:new("**Error:**\n\tAPI rate limit exceeded\n\tPlease wait " .. delay .. " minutes and try again", 0xBB0000))
            else
              msg:reply(embed:new("**Error:**\n\t" .. info.message, 0xBB0000))
            end
          end
        else
          local title = ("**#" .. number .. " | " .. info.title .. " (" .. info.state .. ")**"):sub(256)
          local desc
          if (#info.body > 0) then
            desc = info.body
            if ((#desc) > 2048) then
              desc = desc:sub(2000):match("[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n") .."\n*Visit issue to read more...*"
            end
          else
            desc = "No description given."
          end

          local e = {}
          e.embed = {}
          e.embed.color = 0x00BB00
          e.embed.title = title
          e.embed.description = desc
          e.embed.author = {}
          e.embed.author.name = info.user.login
          e.embed.author.icon_url = info.user.avatar_url
          e.embed.url = info.html_url
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
    for number in msg.content:gmatch("#(%d+)") do
      table.insert(numbers, number)
    end
    post_issues(msg, numbers, false) 
  end, {"messageCreate", "messageUpdate"}, true)

local name = "Issue"
local desc = "Links issues for users"

return module:new(name, desc, {issue}, {interceptor})
