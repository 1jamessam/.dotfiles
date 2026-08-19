return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Mirror of the basedpyright analysis settings in
        -- helix/.config/helix/languages.toml, so Python diagnostics read the same
        -- in both editors: "basic" instead of basedpyright's stricter default
        -- mode, and no reportExplicitAny noise on deliberately-untyped code.
        -- Only these two deviate from the defaults -- autoSearchPaths,
        -- diagnosticMode and useLibraryCodeForTypes are left to nvim-lspconfig,
        -- since anything set here also wins over a project's own
        -- [tool.basedpyright] in pyproject.toml.
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
                diagnosticSeverityOverrides = {
                  reportExplicitAny = "none",
                },
              },
            },
          },
        },
        -- terraform-ls streams its whole job scheduler (JOBS/enqueue/dequeue,
        -- rpc_logger, discover) to stderr, and Nvim records anything a server
        -- writes to stderr in lsp.log at ERROR level: ~13KB/s with a .tf buffer
        -- open, which had grown lsp.log to 225MB. It has no verbosity flag, only
        -- -log-file to redirect the stream. Swap /dev/null for a real path when
        -- debugging the server itself.
        terraformls = {
          cmd = { "terraform-ls", "serve", "-log-file", "/dev/null" },
        },
      },
    },
  },
}
