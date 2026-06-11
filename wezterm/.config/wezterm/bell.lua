local wezterm = require("wezterm")

local M = {}

function M.apply(config)
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

  -- Remember which panes rang the bell so tabs.lua can highlight their tab
  wezterm.on("bell", function(_, pane)
    local bells = wezterm.GLOBAL.bells or {}
    bells[tostring(pane:pane_id())] = true
    wezterm.GLOBAL.bells = bells
  end)
end

return M
