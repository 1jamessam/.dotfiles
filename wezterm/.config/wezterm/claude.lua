-- Claude Code pane integration: <C-'> hides/shows the Claude pane while keeping the
-- editor on screen. Paired with the Neovim provider in
-- nvim/.config/nvim/lua/claude_wezterm.lua, which spawns/reveals the pane.
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- The GUI process (launched from Finder/Dock) doesn't inherit the shell PATH, so
-- `run_child_process({"wezterm", ...})` fails with ENOENT. Call the binary by its
-- absolute path instead.
local wezterm_bin = (wezterm.executable_dir and wezterm.executable_dir .. "/wezterm")
  or "/Applications/WezTerm.app/Contents/MacOS/wezterm"

-- Basename of a pane's foreground process (e.g. "nvim"), or nil if unavailable.
local function foreground(pane)
  local ok, name = pcall(function()
    return pane:get_foreground_process_name()
  end)
  if ok and type(name) == "string" then
    return name:match("[^/\\]+$")
  end
end

-- Identify the editor and Claude panes in the active tab, plus whether the editor
-- is currently zoomed (i.e. Claude is hidden). We anchor on the *editor*: it runs
-- nvim, whose process name is stable. The Claude pane is simply the other one.
-- (Don't identify Claude by its title -- the CLI sets the title to the current task
-- summary, e.g. "✳ Review the PR", so a title-based match is intermittent. Nor by
-- its foreground process, which becomes bash/python/etc. while a tool runs -- which
-- is exactly when you'd want to hide it.)
local function claude_and_editor(window)
  local claude_id, editor_id, editor_zoomed
  for _, item in ipairs(window:mux_window():tabs_with_info()) do
    if item.is_active then
      for _, pi in ipairs(item.tab:panes_with_info()) do
        if not editor_id and foreground(pi.pane) == "nvim" then
          editor_id = pi.pane:pane_id()
          editor_zoomed = pi.is_zoomed
        else
          claude_id = pi.pane:pane_id()
        end
      end
    end
  end
  return claude_id, editor_id, editor_zoomed
end

-- Hide/show the Claude pane. WezTerm has no "hide pane" primitive, so we zoom the
-- *editor* pane instead: a zoomed editor fills the tab (Claude hidden); toggling off
-- restores the split (Claude shown). Zooming the editor rather than Claude is what
-- keeps Neovim visible either way. Focus follows the reveal: showing Claude focuses
-- Claude, hiding it focuses the editor. If Claude isn't running yet, fall through to
-- Neovim to spawn it (it owns the IDE-server env). run_child_process needs the
-- absolute binary -- the GUI PATH lacks it.
---@param window any WezTerm window
---@param pane any active WezTerm pane
function M.toggle(window, pane)
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

return M
