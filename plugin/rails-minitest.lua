if 1 ~= vim.fn.has "nvim-0.9.0" then
  vim.api.nvim_err_writeln "rails-minitest.nvim requires at least nvim-0.9.0."
  return
end

if vim.g.loaded_rails_minitest == 1 then
  return
end

require("rails-minitest")
vim.g.loaded_rails_minitest = 1

