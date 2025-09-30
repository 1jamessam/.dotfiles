local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = "Catppuccin Frappe"
config.keys = {
	{ key = "Backspace", mods = "CMD", action = act.SendKey({ key = "u", mods = "CTRL" }) },
	{ key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
	{ key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
	{ key = "LeftArrow", mods = "CMD", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "RightArrow", mods = "CMD", action = act.SendKey({ key = "e", mods = "CTRL" }) },
	{ key = "f", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
}
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30

return config
