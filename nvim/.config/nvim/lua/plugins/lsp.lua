return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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
