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
config.notification_handling = "AlwaysShow"

-- Flash the pane background briefly when a bell rings
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 120,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 120,
  target = "BackgroundColor",
}
config.colors = { visual_bell = "#2a2a37" }

-- Remember which panes rang the bell so we can highlight their tab
wezterm.on("bell", function(_, pane)
  local bells = wezterm.GLOBAL.bells or {}
  bells[tostring(pane:pane_id())] = true
  wezterm.GLOBAL.bells = bells
end)

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

  -- Resolve the tab's display title
  local title = pane.title
  if (pane.foreground_process_name:match("([^/]+)$") or "") == "nvim" then
    local cwd = pane.current_working_dir
    if cwd then
      local dir = cwd.file_path:match("([^/]+)/?$") or cwd.file_path
      title = " " .. dir .. " "
    end
  end

  -- Highlight tabs with an unacknowledged bell; clear once focused
  local bells = wezterm.GLOBAL.bells or {}
  local pid = tostring(pane.pane_id)
  if tab.is_active then
    if bells[pid] then
      bells[pid] = nil
      wezterm.GLOBAL.bells = bells
    end
  elseif bells[pid] then
    return {
      { Background = { Color = "#e82424" } },
      { Foreground = { Color = "#1f1f28" } },
      { Text = " 🔔" .. title .. " " },
    }
  end

  return title
end)

return config
