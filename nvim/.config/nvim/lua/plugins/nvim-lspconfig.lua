return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticSeverityOverrides = {
                reportUnusedCallResult = "none",
              },
            },
          },
        },
      },
    },
  },
}
