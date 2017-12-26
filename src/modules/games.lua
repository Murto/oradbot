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
						local name = server["name"]
						local players = tonumber(server["players"])
						local max_players = tonumber(server["maxplayers"])
						local mod = server["mods"]
						local state = tonumber(server["state"])
						if (players > 0 and state == 1) then
							sstr = sstr .. "@ " .. name:left_pad(30) .. " | " .. tostring(players):right_pad(3) .. "/" .. tostring(max_players):left_pad(3) .. " | " .. mod .. '\n'
						end
					end
					msg:reply("```\n" .. sstr .. "\n```")
				else
					error("Master server contact failed")
				end
			end)()
	end, 0)


local name = "Games"
local desc = "Displays the current OpenRA games"


return module:new(name, desc, {games}, nil)
