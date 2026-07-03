local wezterm = require("wezterm")

local M = {}

function M.apply(_)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane

    -- Resolve the tab's display title. Show the project dir for editor/shell panes
    -- -- and for the Claude pane too, so toggling Claude's visibility (which shifts
    -- focus between panes) never changes the tab title.
    local title = pane.title
    local process = pane.foreground_process_name:match("([^/]+)$") or ""
    if process == "nvim" or process == "uv" or pane.title:find("Claude") then
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
end

return M
