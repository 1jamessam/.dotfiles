return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      sql = { "sqlfmt" },
      -- sql = { "sqlfluff" },
    },
    linters_by_ft = {
      sql = { "sqlfluff" },
    },
    formatters = {
      stylua = {
        prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/stylua.toml") },
      },
    },
  },
}
