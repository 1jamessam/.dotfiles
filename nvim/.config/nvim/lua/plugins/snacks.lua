return {
  "folke/snacks.nvim",
  opts = {
    explorer = {},
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".mypy_cache", "__pycache__", ".venv" },
        },
        explorer = {
          hidden = true,
          ignored = true,
          -- win = {
          --   input = {
          --     keys = {
          --       ["<C-h>"] = { "<C-w>h", mode = { "i", "n" } },
          --       ["<C-j>"] = { "<C-w>j", mode = { "i", "n" } }, -- This is the same as <C-Down>
          --       ["<C-k>"] = { "<C-w>k", mode = { "i", "n" } },
          --       ["<C-l>"] = { "<C-w>l", mode = { "i", "n" } },
          --     },
          --   },
          -- },
        },
      },
    },
  },
}
