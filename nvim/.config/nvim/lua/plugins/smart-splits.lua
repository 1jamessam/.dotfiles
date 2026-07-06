return {
  "mrjones2014/smart-splits.nvim",
  -- Must NOT be lazy-loaded: the plugin sets (and clears on exit) the IS_NVIM
  -- WezTerm user var that wezterm/.config/wezterm/keys.lua reads to decide whether
  -- <C-hjkl> should move a Neovim split or a WezTerm pane. It has to be active from
  -- the start for that handshake to work.
  lazy = false,
  -- at_edge = "stop": at an outermost split, moving further is a no-op instead of
  -- wrapping to the opposite edge -- so <C-h> from the leftmost (editor) split won't
  -- jump across to the Claude pane on the right. Mirrors the WezTerm-side guard in
  -- wezterm/.config/wezterm/nav.lua.
  opts = { at_edge = "stop" },
  keys = {
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split/pane" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split/pane" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split/pane" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split/pane" },
  },
}
