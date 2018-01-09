local utility = {}

function utility.contains(array, value)
  assert(array, "array cannot be nil")
  assert(value, "value cannot be nil")
  for _, v in ipairs(array) do
    if (v == value) then
      return true
    end
  end
  return false
end

function utility.keys(array)
  assert(array, "array cannot be nil")
  local keys = {}
  for k in pairs(array) do
    table.insert(keys, k)
  end
  return keys
end

return utility
