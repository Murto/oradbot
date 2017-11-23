local utility = {}

function utility.split(p_str)
	local strs = {}
	for str in p_str:gmatch("%S+") do
		table.insert(strs, str)
	end
	return strs
end

function utility.contains(p_array, p_value)
	if (not p_array) then
		return false, "Insufficient arguments."
	end
	for _, v in ipairs(p_array) do
		if (p_value == v) then
			return true
		end
	end
	return false, "Value not found."
end

function utility.left_padded_field(p_str, p_size)
	if (not (p_str and p_size)) then
		return false, "Insufficient arguments"
	end
	local str = p_str:sub(1, p_size)
	return str .. string.rep(" ", p_size - #str)
end

function utility.right_padded_field(p_str, p_size)
	if (not (p_str and p_size)) then
		return false, "Insufficient arguments"
	end
	local str = p_str:sub(1, p_size)
	return string.rep(" ", p_size - #str) .. str
end

function utility.find(p_array, p_value)
	if (not (p_array and p_value)) then
		return false, "Insufficient arguments."
	end
	for index, value in pairs(p_array) do
		if (p_value == value) then
			return index
		end
	end
	return false, "Value not found."
end

function utility.colourful_print(p_text, p_colour)
	print(string.char(27) .. "[" .. tostring(p_colour) .. "m" .. p_text .. string.char(27) .. "[0m")
end

return utility
