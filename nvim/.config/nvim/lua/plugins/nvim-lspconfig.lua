return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      marksman = {
        settings = {
          marksman = {
            diagnostics = {
              disabled = { "MD013/line-length" },
            },
          },
        },
      },
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
