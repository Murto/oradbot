local config = {}
config.options = {}


--	Config Functions

local function split_line(p_line)
	local words = {}
	if (p_line) then
		for word in p_line:gmatch("%S+") do
			table.insert(words, word)
		end
	end
	return words
end

function config.read(p_path)
	if (not p_path) then
		return false, "Insufficient arguments."
	end
	local file = io.open(p_path, "r")
	if (not file) then
		return false, "Could not open file."
	end
	for line in file:lines() do
		local words = split_line(line)
		if (#words > 0) then	
			local option = words[1]
			table.remove(words, 1)
			config.options[option:upper()] = words
		end
	end
	file:close()
	return true
end

function config.write(p_path)
	if (not p_path) then
		return false, "Insufficient arguments."
	end
	local file = io.open(p_path, "w")
	if (not file) then
		return false, "Could not open file."
	end
	for option, words in pairs(config.options) do
		file:write(option)
		for _, word in ipairs(config.options[option]) do
			file:write(" " .. tostring(word))
		end
		file:write("\n")
	end
	file:close()
	return true
end


return config
