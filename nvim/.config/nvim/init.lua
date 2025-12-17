-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.g.tmux_navigator_no_mappings = 1

vim.g.autoformat = false
vim.o.guifont = "JetbrainsMono Nerd Font:h12"

if vim.g.neovide then
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_window_blurred = true
  vim.g.neovide_show_border = true
  vim.g.neovide_remember_window_size = true
end

-- Dataform
vim.filetype.add({
  extension = {
    sqlx = "sql",
  },
  filename = {
    sketchybarrc = "bash",
    bordersrc = "bash",
  },
})
