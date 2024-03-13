local notification = require("rails-minitest/notification")

local RailsMinitest = {
  configuration = {
    enabled = true,
    terminal_command = "kgx -- zsh -ic \"cd . && %CMD% && zsh\"",
    fterm_enabled = true,
    matchers = {
      integration = "^.*test/controllers/(.*)_test.rb$",
      mailer = "^.*test/mailers/(.*)_test.rb$",
      unit = "^.*test/models/(.*)_test.rb$",
      system = "^.*test/system/(.*)_test.rb$",
      controller = "^.*app/controllers/(.*)_controller.rb$",
      model = "^.*app/models/(.*).rb$",
    },
    files_mapping = {
      integration = "app/controllers/%NAME%.rb",
      system = "app/controllers/%NAME%_controller.rb",
      mailer = "app/mailers/%NAME%_mailer.rb",
      unit = "app/models/%NAME%.rb",
      model = "test/models/%NAME%_test.rb",
      controller = {
        "test/controllers/%NAME%_controller_test.rb",
        "test/system/%NAME%_test.rb"
      }
    }
  }
}
local conf

local config = require("rails-minitest/configuration")

RailsMinitest.setup = function(opts)
  conf = config.setup(RailsMinitest.configuration, opts)
  if conf.enabled then
    local fterm_loaded, fterm = pcall(require, "FTerm")
    if not fterm_loaded and conf.fterm_enabled then
      vim.notify(
        "rails-minitest recommands installing FTerm plugin, see https://github.com/numToStr/FTerm.nvim.\n" ..
        "If you don't want to use FTerm at all, set `fterm` to `false` and adjust `terminal_command` in settings.",
        vim.log.levels.WARN,
        notification.markdown("RailsMinitest: FTerm not installed")
      )
    else
      config.set('fterm_loaded', fterm_loaded)
      config.set('fterm', fterm)
    end

    local proxy = require("rails-minitest/proxy")
    proxy.create_user_commands()

    local fs = require("rails-minitest/filesystem")
    fs.create_user_commands()
  end
end

return RailsMinitest
