local command = require("../command")
local embed = require("../embed")
local module = require("../module")

local function get_role(guild, name)
  assert(guild, "guild cannot be nil")
  assert(name, "name cannot be nil")
  name = name:lower()
  for role in guild.roles:iter() do
    if (role.name:lower() == name) then
      return role
    end
  end
  error("No such role")
end


local viewers = command:new("viewers", function(msg)
    local guild = assert(msg.guild, "Roles do note exist outside of guilds")
    local role = get_role(guild, "viewers")
    if (msg.member:hasRole(role))  then
      msg.member:removeRole(role)
      msg:reply(embed:new("You have been removed from the viewers role", 0x00BB00))
    else
      msg.member:addRole(role)
      msg:reply(embed:new("You have been added to the viewers role", 0x00BB00))
    end
  end, 0)


local name = "Roles"
local desc = "Manages selected guild roles"


return module:new(name, desc, {viewers}, nil)
