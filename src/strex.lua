function string.split(str)
  local iter = str:gmatch("%S+")
  local ss = {}
  for s in iter() do
    table.insert(ss, s)
  end
  return unpack(ss)
end

function string.left_pad(str, size)
  local s = str:sub(1, size)
  return s .. string.rep(" ", size - s:len())
end

function string.right_pad(str, size)
  local s = str:sub(1, size)
  return string.rep(" ", size - s:len()) .. s
end
