return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    opts.linters_by_ft = opts.linters_by_ft or {}
    -- actionlint only fires on GitHub Actions workflow YAML (it self-detects
    -- via the filename), so it won't touch helm/terraform/other yaml.
    opts.linters_by_ft.yaml = opts.linters_by_ft.yaml or {}
    table.insert(opts.linters_by_ft.yaml, "actionlint")
    return opts
  end,
}
