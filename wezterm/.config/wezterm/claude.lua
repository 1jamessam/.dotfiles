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
