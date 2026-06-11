local wezterm = require("wezterm")
local act = wezterm.action

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
