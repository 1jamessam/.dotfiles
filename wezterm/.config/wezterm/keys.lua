local wezterm = require("wezterm")
local act = wezterm.action
local claude = require("claude")
local nav = require("nav")

local M = {}

local function spawn_tab_after_current(win, pane)
  local mux_win = win:mux_window()
  for _, item in ipairs(mux_win:tabs_with_info()) do
    if item.is_active then
      mux_win:spawn_tab({})
      win:perform_action(act.MoveTab(item.index + 1), pane)
      return
    end
  end
end

function M.apply(config)
  config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

  config.keys = {
    { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
    -- Hide/show the Claude Code pane (see claude.lua).
    { key = "'", mods = "CTRL", action = wezterm.action_callback(claude.toggle) },
    -- Zoom the focused pane to fill the tab (tmux-style prefix+z); toggle to restore
    -- the split. Works on any pane; <C-'> is the Claude-specific hide/show.
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    -- Seamless Neovim-split / WezTerm-pane navigation (see nav.lua).
    nav.split_nav("h"),
    nav.split_nav("j"),
    nav.split_nav("k"),
    nav.split_nav("l"),
    { key = "t", mods = "CMD", action = wezterm.action_callback(spawn_tab_after_current) },
    { key = "f", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
    { key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
    { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CMD|ALT", action = act.ActivateTabRelative(1) },
    -- keychron keyboard
    { key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
    { key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
    -- lily58 pro keyboard
    { key = "{", mods = "SHIFT|CMD|CTRL", action = act.MoveTabRelative(-1) },
    { key = "}", mods = "SHIFT|CMD|CTRL", action = act.MoveTabRelative(1) },
  }
end

return M
