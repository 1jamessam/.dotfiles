return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            -- reportUnknownVariableType = "none",
            -- analysis = {
            --   diagnosticSeverityOverrides = {
            --     reportUnusedCallResult = "none",
            --     reportUnknownMemberType = "none",
            --     reportAny = "none",
            --     reportUnknownVariableType = "none",
            --   },
            -- },
          },
        },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    enabled = false,
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = {},
    event = "VeryLazy",
    keys = {
      { "<leader>cv", "<CMD>VenvSelect<CR>" },
    },
  },
}
