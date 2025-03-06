-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>")
-- vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>")
-- vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>")
-- vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>")
local wk = require("which-key")

wk.add({
  mode = { "n", "v" },
  { "<leader>p", group = "Python" },
  { "<leader>pu", group = "uv" },
  { "<leader>pui", ":!uv init<CR>", desc = "Initiate project" },
  { "<leader>puv", ":!uv venv<CR>", desc = "Create Virtual Environment" },
})
