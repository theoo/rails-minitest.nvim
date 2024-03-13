local conf = require("rails-minitest/configuration").get()
local notification = require("rails-minitest/notification")

local substitude_destination = function(dest, name)
  return dest:gsub("%%NAME%%", name)
end

local test_destination = function(dest)
  local f = io.open(dest, "r")
  local file_found = f ~= nil
  if file_found then io.close(f) end
  return file_found
end

local edit = function(dest)
  if test_destination(dest) then
      vim.cmd("e " .. dest)
  else
    vim.ui.select(
      { "yes", "no" },
      { prompt = "File " .. dest .. " doesn't exist, do you want to create it?" },
      function(create)
        if create == "yes" then
          vim.cmd("e " .. dest)
        end
      end
    )
  end
end

local M = { buffer_id = nil, filename = nil }

M.execute = function()
  M.buffer_id = vim.api.nvim_get_current_buf()
  M.filename = vim.api.nvim_buf_get_name(M.buffer_id)

  for kind, matcher in pairs(conf.matchers) do
    local name = string.match(M.filename, matcher)
    if name then
      local dest_conf = conf.files_mapping[kind]
      local dest = ""

      if dest_conf == nil then return end

      if type(dest_conf) == "table" then
        local filtered_dest_conf = {}
        local table_size = 0
        for _, d in ipairs(dest_conf) do
          d = substitude_destination(d, name)
          if test_destination(d) then
            table.insert(filtered_dest_conf, d)
            table_size = table_size + 1
          end
        end
        if table_size == 0 then
          return
        elseif table_size == 1 then
          dest = filtered_dest_conf[1]
        else
          vim.ui.select(
            filtered_dest_conf,
            { prompt = "Please choose a destination" },
            function(answer)
              edit(answer)
            end
          )
          return
        end
      elseif type(dest_conf) == "string" then
        dest = substitude_destination(dest_conf, name)
      else
        vim.notify(
          "Configuration issue for entry '" .. kind .. "'. A string or table is expected.",
          vim.log.levels.ERROR,
          notification.markdown("RailsMinitest: Configuration error")
        )
        return
      end

      if dest then edit(dest) end
    end
  end
end

M.create_user_commands = function()
  vim.api.nvim_create_user_command(
    'RailsMinitestJump',
    function()
      if vim.bo.filetype ~= 'ruby' then
        vim.notify('not ruby')
        return
      end
      M.execute()
    end,
    {
      nargs = "*",
      bang = false,
      desc = "Jump from controller/model to test"
    }
  )
end

return M
