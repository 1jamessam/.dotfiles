-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>")
-- vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>")
-- vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>")
-- vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>")
vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Center cursor after moving down half-page"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Center cursor after moving down half-page"})

