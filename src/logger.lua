local logger = {}

function logger:new(file_path)
	assert(file_path, "file_path cannot be nil")
	local l = {}
	setmetatable(l, self)
	self.__index = self
	local msg = nil
	local file, reason = io.open(file_path, "w")
	if (not file) then
		error(reason)
	end
	l.file = file
	return l
end

function logger:log_success(msg)
	assert(msg, "msg cannot be nil")
	self.file:write(string.char(27) .. "[32mSUCCESS" .. string.char(27) .. "[0m: " .. msg .. '\n')
end

function logger:log_warning(msg)
	assert(msg, "msg cannot be nil")
	self.file:write(string.char(27) .. "[33mWARNING" .. string.char(27) .. "[0m: " .. msg .. '\n')
end

function logger:log_error(msg)
	assert(msg, "msg cannot be nil")
	self.file:write(string.char(27) .. "[31mERROR" .. string.char(27) .. "[0m: " .. msg .. '\n')
end

function logger:log_message(msg)
	assert(msg, "msg cannot be nil")
	self.file:write(msg .. '\n')
end

return logger
