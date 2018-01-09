local embed = {}

function embed:new(msg, colour)
  assert(msg, "msg cannot be nil")
  assert(colour, "colour cannot be nil")
  local e = {}
  setmetatable(e, self)
  self.__index = self
  e.embed = {}
  e.embed.color = colour
  e.embed.description = msg
  return e
end

return embed
