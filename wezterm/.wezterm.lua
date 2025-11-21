local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = "Catppuccin Frappe"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
config.native_macos_fullscreen_mode = true
config.font = wezterm.font("JetBrainsMono Nerd Font")

local function close_tab_with_optional_confirm(window, pane)
	local proc = pane:get_foreground_process_name() or ""
	if proc:match("n?vim$") then
		window:perform_action(act.CloseCurrentTab({ confirm = true }), pane)
	else
		window:perform_action(act.CloseCurrentTab({ confirm = false }), pane)
	end
end

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "Backspace", mods = "CMD", action = act.SendKey({ key = "U", mods = "CTRL" }) },
	{ key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
	{ key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
	{ key = "LeftArrow", mods = "CMD", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "RightArrow", mods = "CMD", action = act.SendKey({ key = "e", mods = "CTRL" }) },
	{ key = "f", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
	{ key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action_callback(close_tab_with_optional_confirm),
	},
	{ key = "|", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},
}

-- smart_splits.apply_to_config(config, {
-- 	direction_keys = { "h", "j", "k", "l" },
-- 	modifiers = { move = "CTRL", resize = "META" },
-- 	log_level = "info",
-- })
return config
