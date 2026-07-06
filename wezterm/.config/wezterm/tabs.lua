local wezterm = require("wezterm")
local editor = require("editor")

local M = {}

function M.apply(_)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane

    -- Resolve the tab's display title. Show the project dir for editor/shell panes
    -- -- and for the Claude pane too, so toggling Claude's visibility (which shifts
    -- focus between panes) never changes the tab title.
    local title = pane.title
    local process = editor.basename(pane.foreground_process_name) or ""
    -- The Claude pane runs a plain shell (no nvim process, no IS_NVIM var here in the
    -- tab-title context), so match it by title as a best-effort fallback. This is only
    -- cosmetic; claude.lua deliberately avoids title-matching for the actual pane
    -- targeting because the CLI rewrites the title to its current task.
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
