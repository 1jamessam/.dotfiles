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
    ["Corefile"] = "corefile",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "corefile",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
})

-- Prepend a shellcheck directive to new .env files so SC2034 (unused variable)
-- doesn't fire on plain assignments.
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = { "*.env", ".env", ".env.*" },
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "# shellcheck disable=SC2034", "" })
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

-- Re-add the :LspStart/:LspStop/:LspRestart wrappers. nvim-lspconfig's own
-- command file self-disables on Nvim 0.12+ (it defers to the native vim.lsp
-- API), so these drive vim.lsp.enable directly.
local function active_client_names(args)
  if #args > 0 then
    return args
  end
  return vim
    .iter(vim.lsp.get_clients())
    :map(function(client)
      return client.name
    end)
    :totable()
end

vim.api.nvim_create_user_command("LspStart", function(info)
  vim.lsp.enable(info.fargs)
end, { desc = "Enable and launch a language server", nargs = "?" })

vim.api.nvim_create_user_command("LspStop", function(info)
  for _, name in ipairs(active_client_names(info.fargs)) do
    vim.lsp.enable(name, false)
    for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
      client:stop(true)
    end
  end
end, { desc = "Disable and stop the given client(s)", nargs = "?", bang = true })

vim.api.nvim_create_user_command("LspRestart", function(info)
  local names = active_client_names(info.fargs)
  for _, name in ipairs(names) do
    vim.lsp.enable(name, false)
    for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
      client:stop(true)
    end
  end
  vim.defer_fn(function()
    for _, name in ipairs(names) do
      vim.lsp.enable(name)
    end
  end, 300)
end, { desc = "Restart the given client(s)", nargs = "?" })
