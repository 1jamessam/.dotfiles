local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = "Catppuccin Frappe"
config.native_macos_fullscreen_mode = true
config.font = wezterm.font("JetBrainsMono Nerd Font")

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
	-- { key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
	-- { key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
	-- { key = "LeftArrow", mods = "CMD", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	-- { key = "RightArrow", mods = "CMD", action = act.SendKey({ key = "e", mods = "CTRL" }) },
	{ key = "f", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
	{ key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
	-- { key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	-- { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	-- { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	-- { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
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

