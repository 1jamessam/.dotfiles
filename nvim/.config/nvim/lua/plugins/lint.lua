return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    opts.linters_by_ft = opts.linters_by_ft or {}
    -- actionlint can't self-detect the file kind once nvim-lint strips the
    -- path, so gate it to GitHub Actions workflow YAML and skip helm/terraform/
    -- other yaml. LazyVim's lint autocmd honors this `condition`.
    require("lint").linters.actionlint.condition = function(ctx)
      return ctx.filename:find("[/\\]%.github[/\\]workflows[/\\]") ~= nil
    end
    opts.linters_by_ft.yaml = opts.linters_by_ft.yaml or {}
    table.insert(opts.linters_by_ft.yaml, "actionlint")
    return opts
  end,
}
