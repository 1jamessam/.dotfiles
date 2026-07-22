return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true,
    colors = {
      theme = { all = { ui = { bg_gutter = "none" } } },
    },
    -- transparent = true leaves floats (NormalFloat) opaque; clear them too so
    -- the terminal background shows through pickers, the snacks explorer, etc.
    overrides = function()
      return {
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },
      }
    end,
  },
}
