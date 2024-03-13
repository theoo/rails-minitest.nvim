local config = { _data = {} }

config.get = function()
  return config._data
end

config.set = function(key, value)
  config._data[key] = value
end

config.setup = function(default, user)
  local data = vim.tbl_deep_extend("keep", user or {}, default)
  config._data = data
  return data
end

return config
