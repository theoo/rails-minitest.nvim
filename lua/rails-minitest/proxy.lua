local conf = require("rails-minitest/configuration").get()
local notification = require("rails-minitest/notification")

local M = { buffer_id = nil, filename = nil }

-- TODO: Run tests from application file, not only tests

local run = function(cmd)
  if conf.fterm_loaded and conf.fterm_enabled then
    conf.fterm.run(cmd)
  else
    local term_cmd = conf.terminal_command:gsub("%%CMD%%", cmd)
    os.execute(term_cmd)
  end
end

local ask = function()
  vim.ui.select(
    { "file", "line" },
    { prompt = "Select a command to run:" },
    M.route
  )
end

M.test_file = function()
  local cmd = "rails test " .. M.filename
  run(cmd)
end

M.test_line = function()
  local current_line_number = vim.api.nvim__buf_stats(0).current_lnum
  local cmd = "rails test " .. M.filename .. ":" .. current_line_number
  run(cmd)
end

M.execute = function(cmd)
  M.buffer_id = vim.api.nvim_get_current_buf()
  M.filename = vim.api.nvim_buf_get_name(M.buffer_id)

  local tests = { "integration", "mailer", "unit", "system" }
  local matched = false
  for _, m in ipairs(tests) do
    matched = string.match(M.filename, conf.matchers[m])
    if matched then break end
  end

  if not matched then
    vim.notify(
      "rails-minitest can only be called from a test file. Set `test_file_matcher` in settings " ..
      "to override the file matcher.",
      vim.log.levels.ERROR,
      notification.markdown("RailsMinitest: This file is not recognized as a test file")
    )
    return
  end

  if cmd == nil then
    ask()
  else
    M.route(cmd)
  end
end

M.route = function(cmd)
  local commands = {
    ["ask"] = ask,
    ["file"] = M.test_file,
    ["line"] = M.test_line
  }
  if commands[cmd] ~= nil then
    commands[cmd]()
  else
    vim.notify(
      "Valid commands are 'ask', 'file' and 'line'.",
      vim.log.levels.ERROR,
      notification.markdown("RailsMinitest: Uknown command")
    )
  end
end

M.create_user_commands = function()
  vim.api.nvim_create_user_command(
    'RailsMinitestRun',
    function(opts)
      if vim.bo.filetype ~= 'ruby' then
        vim.notify('not ruby')
        return
      end
      M.execute(opts.fargs[1])
    end,
    {
      nargs = "*",
      bang = false,
      desc = "Run all tests found in this file or just the hovered line"
    }
  )
end

return M
