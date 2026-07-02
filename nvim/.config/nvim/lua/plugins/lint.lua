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

    -- .env files are filetype=sh, so shellcheck flags every KEY=value line as
    -- SC2034 (unused variable). Suppress SC2034 for .env buffers only, keeping
    -- it active for real scripts. Injected as an args function (evaluated per
    -- lint with the target buffer current, like the built-in filename arg); it
    -- must always return a string, so non-.env buffers get a no-op flag.
    require("lint").linters.shellcheck.args = vim.list_extend({
      function()
        local name = vim.api.nvim_buf_get_name(0)
        if name:match("%.env$") or name:match("%.env%.") then
          return "--exclude=SC2034"
        end
        return "--color=never"
      end,
    }, require("lint").linters.shellcheck.args)
    return opts
  end,
}
