-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.g.tmux_navigator_no_mappings = 1

if vim.g.neovide then
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_window_blurred = true
  vim.g.neovide_show_border = true
  vim.g.neovide_remember_window_size = true
end
