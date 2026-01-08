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
        grep = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
