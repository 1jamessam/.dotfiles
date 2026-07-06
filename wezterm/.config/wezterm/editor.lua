-- Shared editor/pane identification for the WezTerm config. Centralizes the "is
-- focus inside a Neovim editor" test and the process-name parsing that claude.lua and
-- nav.lua both need. These were previously copy-pasted into each file and had already
-- drifted -- one checked "nvim" only, the other "nvim" or "vim".
local M = {}

-- Basename of a path or process name (handles both / and \). nil for non-strings.
function M.basename(name)
  if type(name) ~= "string" then
    return nil
  end
  return name:match("[^/\\]+$")
end

-- Foreground process basename of a mux pane, or nil if unavailable.
function M.foreground(pane)
  local ok, name = pcall(function()
    return pane:get_foreground_process_name()
  end)
  if ok then
    return M.basename(name)
  end
end

-- Is focus inside a Neovim editor? Anchor on the IS_NVIM user var that
-- smart-splits.nvim sets -- it stays true even while Neovim runs a foreground
-- subprocess (`:terminal`, `:!uv ...`), whereas the process name then reports the
-- child (uv/caffeinate/etc.). Fall back to the process name for before smart-splits
-- has loaded.
function M.is_editor(pane)
  if pane:get_user_vars().IS_NVIM == "true" then
    return true
  end
  local fg = M.foreground(pane)
  return fg == "nvim" or fg == "vim"
end

return M
