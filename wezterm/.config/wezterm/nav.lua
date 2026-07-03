-- smart-splits.nvim seamless navigation: <C-hjkl> moves between Neovim splits and
-- WezTerm panes with one set of keys. When the focused pane is Neovim (it sets the
-- IS_NVIM user var), forward the key so smart-splits handles it -- including crossing
-- the edge into the adjacent WezTerm pane. Otherwise move the WezTerm pane directly.
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local function is_vim(pane)
  -- Fast path: smart-splits.nvim sets this user var while loaded.
  if pane:get_user_vars().IS_NVIM == "true" then
    return true
  end
  -- Fallback (slower, but keeps <C-hjkl> working inside Neovim even when
  -- smart-splits isn't loaded yet): match the foreground process name.
  local ok, name = pcall(function()
    return pane:get_foreground_process_name()
  end)
  if not ok or type(name) ~= "string" then
    return false
  end
  name = name:gsub("(.*[/\\])(.*)", "%2")
  return name == "nvim" or name == "vim"
end

local direction_keys = { h = "Left", j = "Down", k = "Up", l = "Right" }

-- Return a <C-key> keybinding that navigates to the Neovim split or WezTerm pane in
-- the key's direction.
---@param key "h"|"j"|"k"|"l"
function M.split_nav(key)
  return {
    key = key,
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action(act.SendKey({ key = key, mods = "CTRL" }), pane)
      else
        win:perform_action(act.ActivatePaneDirection(direction_keys[key]), pane)
      end
    end),
  }
end

return M
