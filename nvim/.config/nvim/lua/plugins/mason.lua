return {
  "mason-org/mason.nvim",
  -- Only declare tools that NO enabled LazyVim extra already installs.
  -- LSP servers + extra-bundled tools (ruff, tflint, hadolint, sqlfluff,
  -- markdownlint-cli2, stylua, ...) come from the extras listed in
  -- lazyvim.json, which is the declarative source of truth for those.
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "actionlint", -- GitHub Actions workflow YAML (see lint.lua); no extra
      "prettierd", -- conform js/ts (formatting.lua); no JS/TS extra enabled
      "shellcheck", -- ~/.dotfiles + project shell scripts; no bash extra
      "shfmt",
    })
  end,
}
