local command = require("../command")
local embed = require("../embed")
local module = require("../module")


-- Module commands

local coin = command:new("coin", function(msg)
	local f = ((math.random(2) == 1) and "heads") or "tails"
	local e = embed:new("Flipped " .. f, 0x00BB00)
	msg:reply(e)
  end, 0)

local dice = command:new("dice", function(msg, upper)
    upper = tonumber(upper) or 6
	assert(upper > 0, "upper must be greater than 0")
	local r = math.random(upper)
	local e = embed:new("Rolled " .. r, 0x00BB00)
	msg:reply(e)
  end, 0)


-- Module creation

local name = "Random"
local desc = "Provides random output for users"

return module:new(name, desc, {coin, dice}, nil)
