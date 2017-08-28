local utility = {}

function utility.split_command(p_command)
	local strs = {}
	for str in p_command:gmatch("%S+") do
		table.insert(strs, str)
	end
	return strs
end

return utility
