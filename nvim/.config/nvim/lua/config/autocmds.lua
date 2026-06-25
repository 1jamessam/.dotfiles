-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown,sql,Dockerfile",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "sql",
--   callback = function()
--     vim.bo.shiftwidth = 4
--     vim.bo.tabstop = 4
--     vim.bo.expandtab = true
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "xml",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.expandtab = true
  end,
})

vim.filetype.add({
  filename = {
    [".sqlfluff"] = "dosini",
  },
})

-- Prepend a shellcheck directive to new .env files so SC2034 (unused variable)
-- doesn't fire on plain assignments.
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = { "*.env", ".env", ".env.*" },
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "# shellcheck disable=SC2034", "" })
  end,
})
