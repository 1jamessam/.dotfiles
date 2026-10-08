-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local indent_by_ft = {
  markdown = 4,
  sql = 4,
  sqlx = 4,
  dockerfile = 4,
  corefile = 4,
  xml = 2,
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_indent", { clear = true }),
  pattern = vim.tbl_keys(indent_by_ft),
  callback = function(args)
    local width = indent_by_ft[args.match]
    vim.bo[args.buf].shiftwidth = width
    vim.bo[args.buf].tabstop = width
    vim.bo[args.buf].expandtab = true
  end,
})

-- terraform-ls' semantic-token *delta* responses drift out of alignment with
-- the buffer, smearing italic type/property highlights mid-identifier until the
-- buffer is reloaded. Force full (non-delta) requests so tokens always realign.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "terraformls" then
      local caps = client.server_capabilities.semanticTokensProvider
      if caps and caps.full == true then
        caps.full = { delta = false }
      elseif type(caps) == "table" and type(caps.full) == "table" then
        caps.full.delta = false
      end
    end
  end,
})

-- trouble.nvim's lualine symbol breadcrumb emits its trailing separator with no
-- highlight, so that cell falls back to StatusLine (#16161d under kanagawa) and
-- shows as a black box against the lualine_c section (#2a2a37). Keep
-- StatusLine's background in sync with the section it sits in. lualine only
-- defines lualine_c_normal once it has drawn, so this runs after startup and on
-- every colorscheme change rather than at load time.
local function sync_statusline_bg()
  local section = vim.api.nvim_get_hl(0, { name = "lualine_c_normal", link = false })
  if not section.bg then
    return
  end
  local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  statusline.bg = section.bg
  vim.api.nvim_set_hl(0, "StatusLine", statusline)
end

vim.api.nvim_create_autocmd({ "ColorScheme", "User" }, {
  pattern = { "*", "LazyVimStarted" },
  callback = function()
    vim.defer_fn(sync_statusline_bg, 50)
  end,
})
