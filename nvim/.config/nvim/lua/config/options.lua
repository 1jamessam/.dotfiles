-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- .env files are filetype=sh, so bash-language-server runs shellcheck on them
-- and flags every KEY=value line as SC2034 (unused variable). Drop SC2034 from
-- diagnostics for .env buffers only; real shell scripts keep the check. This
-- wraps the global LSP handler here (loaded at startup) rather than in an
-- autocmd or a per-server config: config/autocmds.lua only loads on VeryLazy,
-- which is too late for a .env file opened at launch, and LazyVim's server-opts
-- merge drops a bashls `handlers` override.
local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  local uri = result and result.uri or ""
  if (uri:match("%.env$") or uri:match("%.env%.")) and result and result.diagnostics then
    result.diagnostics = vim.tbl_filter(function(d)
      return d.code ~= "SC2034"
    end, result.diagnostics)
  end
  return default_publish_diagnostics(err, result, ctx, config)
end
