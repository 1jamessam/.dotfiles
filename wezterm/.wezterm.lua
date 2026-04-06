local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- config.color_scheme = "Catppuccin Frappe"
config.color_scheme = "Kanagawa (Gogh)"
config.native_macos_fullscreen_mode = true
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12
config.window_decorations = "RESIZE"
config.adjust_window_size_when_changing_font_size = false
config.show_close_tab_button_in_tabs = false -- nightly build
-- config.automatically_reload_config = false

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

local function spawn_tab_after_current(win, pane)
  local mux_win = win:mux_window()
  for _, item in ipairs(mux_win:tabs_with_info()) do
    if item.is_active then
      mux_win:spawn_tab {}
      win:perform_action(act.MoveTab(item.index + 1), pane)
      return
    end
  end
end

config.keys = {
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
  { key = "t", mods = "CMD", action = wezterm.action_callback(spawn_tab_after_current) },
  { key = "f", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
  { key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = false } },
  { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CMD|ALT", action = act.ActivateTabRelative(1) },
  -- keychron keyboard
  { key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
  { key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
  -- lily58 pro keyboard
  { key = "{", mods = "SHIFT|CMD|CTRL", action = act.MoveTabRelative(-1) },
  { key = "}", mods = "SHIFT|CMD|CTRL", action = act.MoveTabRelative(1) },
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local process_name = pane.foreground_process_name:match("([^/]+)$") or ""
  if process_name == "nvim" then
    local cwd = pane.current_working_dir
    if cwd then
      local dir = cwd.file_path:match("([^/]+)/?$") or cwd.file_path
      return " " .. dir .. " "
    end
  end
  return tab.active_pane.title
end)

return config
