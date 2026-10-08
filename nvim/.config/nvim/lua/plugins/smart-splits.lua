local function set_user_var(name, value)
  local seq = string.format("\x1b]1337;SetUserVar=%s=%s\a", name, vim.base64.encode(value))
  vim.api.nvim_chan_send(vim.v.stderr, seq)
end

return {
  "mrjones2014/smart-splits.nvim",
  -- Must NOT be lazy-loaded: init sets (and clears on exit) the IS_NVIM WezTerm user
  -- var that wezterm/.config/wezterm/editor.lua reads to decide whether <C-hjkl>
  -- should move a Neovim split or a WezTerm pane. smart-splits v2 core no longer
  -- sets it (that moved to the WezTerm backend plugin, which we don't use), so we
  -- send it ourselves.
  lazy = false,
  init = function()
    set_user_var("IS_NVIM", "true")
    vim.api.nvim_create_autocmd("ExitPre", {
      callback = function()
        set_user_var("IS_NVIM", "")
      end,
    })
  end,
  -- No mux backend: don't let smart-splits cross into WezTerm panes by shelling out
  -- to `wezterm cli` -- a single edge hop spawns ~6 blocking subprocesses on the UI
  -- thread (visible lag switching Neovim -> Claude). Instead, at an outermost split
  -- we set the SMART_SPLITS_NAV WezTerm user var and let wezterm/.config/wezterm/nav.lua
  -- do the hop natively (in-process, instant). has_neighbor there provides the same
  -- no-wrap guard the old at_edge = "stop" gave us: <C-h> from the leftmost split is a
  -- no-op because there's no WezTerm pane on the left.
  opts = {
    move = {
      at_edge = function(ctx)
        set_user_var("SMART_SPLITS_NAV", ctx.direction)
      end,
    },
  },
  -- mode n+i: without an insert-mode mapping, <C-hjkl> falls through to Neovim's
  -- default and inserts the literal control char (e.g. <C-l> -> ^L) instead of
  -- navigating. Crossing runs a wincmd, so you land in normal mode in the target.
  keys = {
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, mode = { "n", "i" }, desc = "Move to left split/pane" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, mode = { "n", "i" }, desc = "Move to below split/pane" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, mode = { "n", "i" }, desc = "Move to above split/pane" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, mode = { "n", "i" }, desc = "Move to right split/pane" },
  },
}
