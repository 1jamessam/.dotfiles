return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      stylua = {
        prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/stylua.toml") },
      },
    },
  },
}
