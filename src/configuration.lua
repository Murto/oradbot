local configuration = {}


-- Section

configuration.section = {}

function configuration.section:new(name, properties)
	assert(name, "name cannot be nil")
	local s = {}
	setmetatable(s, self)
	self.__index = self
	s.name = name
	s.properties = {}
	if (properties) then
		for _, p in pairs(properties) do
			s.properties[p.name] = p
		end
	end
	return s
end

function configuration.section:get_property(name)
	assert(name, "name cannot be nil")
	return self.properties[name]
end


-- Property

configuration.property = {}

function configuration.property:new(name, values)
	assert(name, "name cannot be nil")
	local p = {}
	setmetatable(p, self)
	self.__index = self
	p.name = name
	p.values = values or {}
	return p
end

function configuration.property:get_value(index)
	assert(index, "index cannot be nil")
	return self.values[index]
end

function configuration.property:get_values()
	return {unpack(self.values)}
end

-- Configuration

function configuration:new(file_path, sections)
	assert(file_path, "file_path cannot be nil")
	local c = {}
	setmetatable(c, self)
	self.__index = self
	c.file_path = file_path
	c.sections = {}
	if (sections) then
		for _, s in pairs(sections) do
			c.sections[s.name] = s
		end
	end
	return c
end

function configuration:get_section(name)
	assert(name, "name cannot be nil")
	return self.sections[name]
end


-- Patterns

local whitespace_pattern = "^%s*$"
local section_pattern = "^%s*%[%S+%]%s*$"
local property_pattern = "^%s*%S+%s*=.*$"

local line = nil

local function parse_property(line)
	local name = line:match("%S+")
	local values = {}
	for value in line:match("=(.*)"):gmatch("%S+") do
		table.insert(values, value)
	end
	return configuration.property:new(name, values)
end

local function parse_section(iter)
	local name = line:match("%[(%S+)%]")
	local props = {}
	line = iter()
	while (line) do
		if (line:match(property_pattern)) then
			local prop = parse_property(line)
			table.insert(props, prop)
		elseif (not line:match(whitespace_pattern)) then
			break
		end
		line = iter()
	end
	return configuration.section:new(name, props)
end


function configuration:read()
	local iter = {}
	setmetatable(iter, {__call = io.lines(self.file_path)})
	local sections = {}
	line = iter()
	while (line) do
		if (line:match(section_pattern)) then
			local section = parse_section(iter)
			sections[section.name] = section
		elseif (not line:match(whitespace_pattern)) then
			error("Parse error at line:\n\t" .. line)
		else
			line = iter()
		end
	end
	self.sections = sections
end

function configuration:write()
	local file = io.open(self.file_path, "w")
	for name, section in pairs(self.sections) do
		file:write("[" .. name .. "]\n")
		for name, property in pairs(section.properties) do
			file:write(name .. " =")
			for _, value in ipairs(property.values) do
				file:write(" " .. value)
			end
			file:write("\n")
		end
		file:write("\n")
	end
	file:close()
end

return configuration
