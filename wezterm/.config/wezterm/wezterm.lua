local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("appearance").apply(config)
require("keys").apply(config)
require("tabs").apply(config)
require("bell").apply(config)

return config
