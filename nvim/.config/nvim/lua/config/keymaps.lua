-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>")
-- vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>")
-- vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>")
-- vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>")

vim.keymap.set("n", "<leader>dm", function()
  require("dap-python").test_method()
end, { desc = "Debug Test Method" })
