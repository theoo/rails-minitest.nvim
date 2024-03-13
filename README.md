# rails-minitest.nvim

rails-minitest.nvim provide simple tools to:

- jump across your tests and your code
- run tests: either the hovered function, the whole file or all tests

This plugins relies on the _rails naming convention_. This means that a controller named `extra/examples_controller.rb`
will try to match functional tests named `system/extra/examples_tests.rb` or integration tests named
`controllers/extra/examples_controller_test.rb`. In this case the scope is `extra` and the name is `examples`.
You can inflect other destination folder, for each test group, but scopes and names cannot be mapped yet.
I stand for then "convention over configuration" moto, but if you have concrete use-case that requires a name mapping,
please open a ticket.

## TODO

- doc
- test

## Dependencies

### soft requirements

- Fterm

## Installation and Setup

with [packer](https://www.github.com/wbthomason/packer.nvim):

```lua
use {
    "theoreichel/rails-minitest.nvim",
    requires = { "numToStr/Fterm.nvim" }
}
```

Then somewhere if not in your plugin file directly, call the setup function like this:

```lua
rails_minitest.setup()
```

You can override default settings by providing a _list_ to the `setup({})` function.

[The default configuration is](lua/rails-minitest/init.lua):

```lua
  config = {
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
```

### Call User Commands

Map a keyboard shortcut to:

- `RailsMinitestRun line`
- `RailsMinitestRun file`
- `RailsMinitestJump`

TODO: Improve doc

### Customize matchers

The [config](lua/rails-minitest/init.lua) is self-explanatory. There is two kind of matchers:

- `matchers` filter files where the plugin can be called. It extracts the _basename_ of your file;
- `files_mapping` use to jump over files using the previously extracted _basename_

### Use an external terminal

You can use the terminal of your choice to run tests in it. If you don't want to use `FTerm`, disable it with
`fterm_enabled = false` and customize the command line with `terminal_command = ...`. For instance:

```lua
rails_minitest.setup({
  terminal_command = "gnome-terminal -- zsh -ic \"cd . && %CMD% && zsh\"",
  fterm_enabled = false
})
```
