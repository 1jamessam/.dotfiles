local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  -- config.color_scheme = "Catppuccin Frappe"
  config.color_scheme = "Kanagawa (Gogh)"
  config.native_macos_fullscreen_mode = true
  -- SF Pro is the fallback so the SF Symbols codepoints in the sketchybar
  -- config render instead of tripping WezTerm's missing-glyph warning.
  config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "SF Pro" })
  config.font_size = 12
  config.window_decorations = "RESIZE"
  config.window_background_opacity = 0.90
  config.macos_window_background_blur = 20
  -- The Claude Code CLI paints an explicit cell background, so without this it
  -- stays opaque while the (default-bg) nvim pane goes transparent. Match them.
  -- config.text_background_opacity = 0.95
  config.adjust_window_size_when_changing_font_size = false
  config.show_close_tab_button_in_tabs = false -- nightly build
  -- config.automatically_reload_config = false
end

return M
