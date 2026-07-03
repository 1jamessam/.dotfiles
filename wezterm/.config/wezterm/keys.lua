local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local function spawn_tab_after_current(win, pane)
  local mux_win = win:mux_window()
  for _, item in ipairs(mux_win:tabs_with_info()) do
    if item.is_active then
      mux_win:spawn_tab({})
      win:perform_action(act.MoveTab(item.index + 1), pane)
      return
    end
  end
end

-- The GUI process (launched from Finder/Dock) doesn't inherit the shell PATH, so
-- `run_child_process({"wezterm", ...})` fails with ENOENT. Call the binary by its
-- absolute path instead.
local wezterm_bin = (wezterm.executable_dir and wezterm.executable_dir .. "/wezterm")
  or "/Applications/WezTerm.app/Contents/MacOS/wezterm"

-- The Claude Code CLI titles its pane "✳ Claude Code".
local function title_is_claude(pane)
  local ok, title = pcall(function()
    return pane:get_title()
  end)
  return ok and type(title) == "string" and title:find("Claude") ~= nil
end

-- Identify the Claude pane and its sibling (the editor) in the active tab, plus
-- whether the editor is currently zoomed (i.e. Claude is hidden).
local function claude_and_editor(window)
  local claude_id, editor_id, editor_zoomed
  for _, item in ipairs(window:mux_window():tabs_with_info()) do
    if item.is_active then
      for _, pi in ipairs(item.tab:panes_with_info()) do
        if title_is_claude(pi.pane) then
          claude_id = pi.pane:pane_id()
        elseif not editor_id then
          editor_id = pi.pane:pane_id()
          editor_zoomed = pi.is_zoomed
        end
      end
    end
  end
  return claude_id, editor_id, editor_zoomed
end

-- <C-'> hides/shows the Claude pane while keeping the editor on screen. WezTerm has
-- no "hide pane" primitive, so we zoom the *editor* pane instead: a zoomed editor
-- fills the tab (Claude hidden); toggling off restores the split (Claude shown).
-- Zooming the editor rather than Claude is what keeps Neovim visible either way.
-- Focus follows the reveal: showing Claude focuses Claude, hiding it focuses the
-- editor. If Claude isn't running yet, fall through to Neovim to spawn it (it owns
-- the IDE-server env). run_child_process needs the absolute binary -- GUI PATH lacks it.
local function toggle_claude(window, pane)
  local claude_id, editor_id, editor_zoomed = claude_and_editor(window)
  if not claude_id then
    window:perform_action(act.SendKey({ key = "'", mods = "CTRL" }), pane)
    return
  end
  if not editor_id then
    return
  end
  wezterm.run_child_process({ wezterm_bin, "cli", "zoom-pane", "--pane-id", tostring(editor_id), "--toggle" })
  -- editor_zoomed was Claude's hidden state, so toggling now reveals it -> focus
  -- Claude; otherwise we just hid Claude -> focus the editor.
  local focus_id = editor_zoomed and claude_id or editor_id
  wezterm.run_child_process({ wezterm_bin, "cli", "activate-pane", "--pane-id", tostring(focus_id) })
end

-- smart-splits.nvim seamless navigation: <C-hjkl> moves between Neovim splits and
-- WezTerm panes with one set of keys. When the focused pane is Neovim (it sets the
-- IS_NVIM user var), forward the key so smart-splits handles it -- including
-- crossing the edge into the adjacent WezTerm pane. Otherwise move the WezTerm pane
-- directly.
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

local function split_nav(key)
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

function M.apply(config)
  config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

  config.keys = {
    { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
    { key = "'", mods = "CTRL", action = wezterm.action_callback(toggle_claude) },
    -- Zoom the focused pane to fill the tab (tmux-style prefix+z); toggle to restore
    -- the split. Works on any pane; <C-'> is the Claude-specific hide/show.
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    split_nav("h"),
    split_nav("j"),
    split_nav("k"),
    split_nav("l"),
    { key = "t", mods = "CMD", action = wezterm.action_callback(spawn_tab_after_current) },
    { key = "f", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
    { key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
    { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CMD|ALT", action = act.ActivateTabRelative(1) },
    -- keychron keyboard
    { key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
    { key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
    -- lily58 pro keyboard
    { key = "{", mods = "SHIFT|CMD|CTRL", action = act.MoveTabRelative(-1) },
    { key = "}", mods = "SHIFT|CMD|CTRL", action = act.MoveTabRelative(1) },
  }
end

return M
