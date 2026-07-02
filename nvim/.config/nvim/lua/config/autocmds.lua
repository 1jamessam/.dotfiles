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

-- nvim-treesitter's `main` branch starts the highlighter once via a FileType
-- autocmd and never re-attaches it. terraform_fmt on save (auto-save + conform)
-- rewrites the buffer and can drop the HCL highlighter, leaving the file
-- unhighlighted until a reload. Re-start it on save if it died.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.tf", "*.tfvars", "*.hcl" },
  callback = function(ev)
    if not vim.treesitter.highlighter.active[ev.buf] then
      pcall(vim.treesitter.start, ev.buf)
    end
  end,
})
