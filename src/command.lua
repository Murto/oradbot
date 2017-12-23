local command = {}

function command:new(name, func, level)
	assert(name, "name cannot be nil")
	assert(func, "func cannot be nil")
	if (level) then
		assert(level <= 100, "Level too high")
	end
	local c = {}
	setmetatable(c, self)
	self.__index = self
	c.name = name
	c.func = func
	c.level = level or 0
	return c
end

function command:get_name()
	return self.name
end

function command:get_level()
	return self.level
end

function command:run(msg, params)
	assert(msg, "msg cannot be nil")
	params = params or {}
	self.func(msg, unpack(params))
end

return command
