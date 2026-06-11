return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    -- linter for GitHub Actions workflow YAML (used by lint.lua)
    table.insert(opts.ensure_installed, "actionlint")
  end,
}
