local command = require("../command")
local embed = require("../embed")
local module = require("../module")


local execute = command:new("execute", function(msg, ...)
		local trailing = {select(1, ...)}
		assert(#trailing > 0, "Nothing to execute")
		local code = table.concat(trailing, " "):match("```lua(.*)```")
		local f = load(code)
		local start = os.clock()
		local result = f()
		local duration = os.clock() - start
		msg:reply(embed:new("Ran in " .. string.format("%.3f", duration) .. " seconds\nResult: " .. result, 0x00BB00))
	end, 100)


local name = "Execute"
local desc = "Executes arbitrary lua code"


return module:new(name, desc, {execute}, nil)
