return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      progress = {
        -- Curbs <C-l> nav lag: the LSP progress spinner repaints at noice's default
        -- ~30x/sec, flooding the pty that the SMART_SPLITS_NAV OSC (see
        -- wezterm/.../nav.lua) also rides, so WezTerm reaches the cross signal late.
        -- Thinning the redraw rate to ~10/sec cuts the flood to a third while keeping
        -- the spinner. If lag persists, set `enabled = false` to remove it entirely.
        throttle = 1000 / 10, -- ~10 redraws/sec (default is 1000/30)
      },
    },
  },
}
