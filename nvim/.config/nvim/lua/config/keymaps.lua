-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>")
-- vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>")
-- vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>")
-- vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center cursor after moving down half-page" })
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center cursor after moving down half-page" })

vim.keymap.set("n", "<leader>fy", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path, "c")
  vim.notify("Copied: " .. path)
end, { desc = "Copy file path (relative)" })

vim.keymap.set({ "n", "x" }, "<leader>gR", function()
  Snacks.gitbrowse({ what = "repo" })
end, { desc = "Git Browse Repo (open)" })

vim.keymap.set("n", "<leader>gp", function()
  vim.system({ "gh", "pr", "view", "--web" }, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify(vim.trim(res.stderr), vim.log.levels.WARN)
      end)
    end
  end)
end, { desc = "Open PR for current branch" })

vim.keymap.set("n", "<leader>gP", function()
  Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
