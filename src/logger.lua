local logger = {}

function logger:new(file_path)
	local l = {}
	setmetatable(l, self)
	self.__index = self
	local msg = nil
	local file, msg = io.open(file_path, "w")
	if (not file) then
		error(msg)
	end
	l.file = file
	return l
end

function logger:log_success(msg)
	self.file:write(string.char(27) .. "[32mSUCCESS:\n    " .. msg .. string.char(27) .. "[0m\n")
end

function logger:log_warning(msg)
	self.file:write(string.char(27) .. "[33mERROR:\n    " .. msg .. string.char(27) .. "[0m\n")
end

function logger:log_error(msg)
	self.file:write(string.char(27) .. "[31mERROR:\n    " .. msg .. string.char(27) .. "[0m\n")
end

function logger:log_message(msg)
	self.file:write(msg .. '\n')
end

return logger
