local utility = {}

function utility.split(p_str)
	local strs = {}
	for str in p_str:gmatch("%S+") do
		table.insert(strs, str)
	end
	return strs
end

function utility.to_set(p_array)
	local set = {}
	for _, v in ipairs(p_array) do
		set[v] = true
	end
	return set
end

function utility.to_array(p_set)
	local array = {}
	for v, _ in pairs(p_set) do
		table.insert(array, v)
	end
	return array
end

return utility
