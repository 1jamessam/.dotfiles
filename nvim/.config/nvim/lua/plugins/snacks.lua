return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = {},
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".mypy_cache", "__pycache__" },
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
