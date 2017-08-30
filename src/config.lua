local utility = require("utility")
local config = {}

function config.read(p_path)
	local file, reason = io.open(p_path, "r")
	if (not file) then
		print(reason)
	end
	local options = {}
	local line = file:read("*line")
	while (line) do
		local option = utility.split(line)
		if (#option > 0) then
			local name = option[1]
			table.remove(option, 1)
			options[name] = option
		end
		line = file:read("*line")
	end
	file:close()
	return options
end

function config.write(p_path, p_options)
	local file, reason = io.open(p_path, "w")
	if (not file) then
		print(reason)
		return false
	end
	for name, values in pairs(p_options) do	
		file:write(name)
		for _, value in ipairs(values) do
			file:write(" " .. value)
		end
		file:write("\n")
	end
	file:close()
	return true
end

return config
