local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

config.color_scheme = 'Catppuccin Frappe'
config.keys = {
	{ key = "Backspace", mods = "CMD", action = action.SendString("\x15") },
}

return config
