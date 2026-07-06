-- smart-splits.nvim seamless navigation: <C-hjkl> moves between Neovim splits and
-- WezTerm panes with one set of keys. When the focused pane is Neovim (it sets the
-- IS_NVIM user var), forward the key so smart-splits handles it -- including crossing
-- the edge into the adjacent WezTerm pane. Otherwise move the WezTerm pane directly.
local wezterm = require("wezterm")
local act = wezterm.action
local editor = require("editor")

local M = {}

local direction_keys = { h = "Left", j = "Down", k = "Up", l = "Right" }

-- Is there a WezTerm pane adjacent to the active one in `dir`? ActivatePaneDirection
-- otherwise wraps to the opposite edge, so at the rightmost (Claude) pane a <C-l>
-- would cycle back to the editor. Compare cell rects: require a pane on the correct
-- side plus overlap on the perpendicular axis so a diagonal pane doesn't count.
-- NOTE: this is the WezTerm-side twin of pick_nav() in
-- nvim/.config/nvim/lua/plugins/snacks.lua -- same "nearest neighbour in direction X
-- with perpendicular overlap" test, against WezTerm panes instead of Neovim windows.
-- Fix edge-case bugs in both.
---@param win any WezTerm window
---@param dir "Left"|"Down"|"Up"|"Right"
local function has_neighbor(win, dir)
  local tab = win:active_tab()
  if not tab then
    return false
  end
  local infos = tab:panes_with_info()
  local active
  for _, p in ipairs(infos) do
    if p.is_active then
      active = p
      break
    end
  end
  if not active then
    return false
  end
  for _, p in ipairs(infos) do
    if not p.is_active then
      local horiz_overlap = p.left < active.left + active.width and active.left < p.left + p.width
      local vert_overlap = p.top < active.top + active.height and active.top < p.top + p.height
      if dir == "Left" and p.left < active.left and vert_overlap then
        return true
      elseif dir == "Right" and p.left > active.left and vert_overlap then
        return true
      elseif dir == "Up" and p.top < active.top and horiz_overlap then
        return true
      elseif dir == "Down" and p.top > active.top and horiz_overlap then
        return true
      end
    end
  end
  return false
end

-- Return a <C-key> keybinding that navigates to the Neovim split or WezTerm pane in
-- the key's direction.
---@param key "h"|"j"|"k"|"l"
function M.split_nav(key)
  return {
    key = key,
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local dir = direction_keys[key]
      if editor.is_editor(pane) then
        win:perform_action(act.SendKey({ key = key, mods = "CTRL" }), pane)
      elseif has_neighbor(win, dir) then
        win:perform_action(act.ActivatePaneDirection(dir), pane)
      end
    end),
  }
end

return M
