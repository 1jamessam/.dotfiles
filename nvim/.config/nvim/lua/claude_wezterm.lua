--- Custom claudecode.nvim terminal provider that runs the Claude CLI in a WezTerm
--- split pane instead of an in-editor terminal buffer.
---
--- Division of labour: claudecode.nvim owns the IDE side -- the WebSocket/MCP server,
--- the ~/.claude/ide/<port>.lock file, and the selection/diff/diagnostics integration,
--- all of which live in Neovim. This module owns only *bringing Claude up*: it spawns
--- the CLI as a WezTerm split wired to that server, reveals it, focuses it, and kills
--- it. Hiding/showing is a WezTerm concern -- <C-'> zooms the editor pane to hide
--- Claude (see wezterm/.config/wezterm/keys.lua) -- so this provider only ever
--- *reveals* (unzooms), never hides.
---
--- Gotcha in spawn(): `wezterm cli split-pane` creates the pane in the WezTerm mux
--- server, so the new program inherits the mux server's environment, NOT that of the
--- short-lived `wezterm cli` client. CLAUDE_CODE_SSE_PORT et al. must therefore be
--- injected into the spawned program via an `env K=V ...` prefix -- see build_program().
---
---@type ClaudeCodeTerminalProvider
local M = {}

-- The pane we spawned, kept in a Neovim global (not a module local) so it survives
-- `:Lazy reload` / a fresh require. Re-validated against the live pane list before use.
local function tracked_pane()
  return vim.g.claude_wezterm_pane_id
end
local function set_tracked(id)
  vim.g.claude_wezterm_pane_id = id
end

---Run a `wezterm cli` subcommand synchronously.
---@param args string[]
---@return boolean ok, string stdout, string stderr
local function wezterm(args)
  local res = vim.system(vim.list_extend({ "wezterm", "cli" }, args), { text = true }):wait()
  return res.code == 0, res.stdout or "", res.stderr or ""
end

---This Neovim instance's own WezTerm pane.
---@return integer?
local function editor_pane_id()
  return tonumber(vim.env.WEZTERM_PANE)
end

---@param pane_id integer?
local function activate(pane_id)
  if pane_id then
    wezterm({ "activate-pane", "--pane-id", tostring(pane_id) })
  end
end

---Is the tracked Claude pane still alive in the mux?
---@return boolean
local function claude_alive()
  local cid = tracked_pane()
  if not cid then
    return false
  end
  local ok, out = wezterm({ "list", "--format", "json" })
  if not ok or out == "" then
    return false
  end
  local decoded_ok, panes = pcall(vim.json.decode, out)
  if not decoded_ok or type(panes) ~= "table" then
    return false
  end
  for _, p in ipairs(panes) do
    if p.pane_id == cid then
      return true
    end
  end
  return false
end

---Reveal Claude if <C-'> hid it, by unzooming the editor pane so the split is
---restored. A no-op when nothing is zoomed.
local function reveal()
  local eid = editor_pane_id()
  if eid then
    wezterm({ "zoom-pane", "--pane-id", tostring(eid), "--unzoom" })
  end
end

---Build the pane's argv: `env K=V ... claude [args]` (see the module header).
---@param cmd_string string?
---@param env_table table?
---@return string[]
local function build_program(cmd_string, env_table)
  local parts = { "env" }
  for k, v in pairs(env_table or {}) do
    parts[#parts + 1] = string.format("%s=%s", k, tostring(v))
  end
  local cmd_parts = require("claudecode.utils").parse_command(cmd_string or "claude") or { "claude" }
  return vim.list_extend(parts, cmd_parts)
end

---Spawn a fresh Claude pane as a split of the editor and record its id.
---WezTerm focuses the new split by default.
---@param cmd_string string
---@param env_table table
---@param cfg table
local function spawn(cmd_string, env_table, cfg)
  local editor = editor_pane_id()
  local args = { "split-pane" }
  if editor then
    vim.list_extend(args, { "--pane-id", tostring(editor) })
  end
  vim.list_extend(args, { cfg.split_side == "left" and "--left" or "--right" })
  vim.list_extend(args, { "--percent", tostring(math.floor((cfg.split_width_percentage or 0.4) * 100 + 0.5)) })
  local cwd = cfg.cwd or vim.fn.getcwd()
  if cwd and cwd ~= "" then
    vim.list_extend(args, { "--cwd", cwd })
  end
  vim.list_extend(args, { "--" })
  vim.list_extend(args, build_program(cmd_string, env_table))

  local ok, out, err = wezterm(args)
  if not ok then
    vim.notify("claude-wezterm: split-pane failed: " .. err, vim.log.levels.ERROR)
    return
  end
  set_tracked(tonumber((out:gsub("%s+$", ""))))
end

-- claudecode.nvim ClaudeCodeTerminalProvider interface --------------------------

function M.setup(_) end

---Ensure Claude is running and visible: spawn it if absent, otherwise reveal it
---(undoing a <C-'> zoom-hide). `focus == false` keeps the cursor in the editor.
---@param cmd_string string
---@param env_table table
---@param cfg table
---@param focus boolean|nil defaults to true
function M.open(cmd_string, env_table, cfg, focus)
  if not claude_alive() then
    spawn(cmd_string, env_table, cfg) -- spawn focuses the new pane
  else
    reveal()
  end
  if focus == false then
    activate(editor_pane_id())
  else
    activate(tracked_pane())
  end
end

function M.close()
  local cid = tracked_pane()
  if cid then
    wezterm({ "kill-pane", "--pane-id", tostring(cid) })
  end
  set_tracked(nil)
end

-- Hiding is <C-'>'s job (WezTerm zoom); from Neovim these only ever bring Claude up.
M.simple_toggle = M.open
M.focus_toggle = M.open

---No Neovim buffer backs an external pane.
---@return nil
function M.get_active_bufnr()
  return nil
end

---@return boolean
function M.is_available()
  return vim.fn.executable("wezterm") == 1 and vim.env.WEZTERM_PANE ~= nil
end

---@return table?
function M._get_terminal_for_test()
  local cid = tracked_pane()
  return cid and { pane_id = cid } or nil
end

return M
