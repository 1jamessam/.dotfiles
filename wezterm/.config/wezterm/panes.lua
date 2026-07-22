-- tmux-style break-pane / join-pane, backed by `wezterm cli`. WezTerm has no native
-- action for moving an existing pane into a split, so both operations shell out to the
-- CLI. Use executable_dir rather than a bare "wezterm" so it resolves regardless of the
-- GUI's PATH (the macOS app bundle ships the CLI next to wezterm-gui).
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local cli = wezterm.executable_dir .. "/wezterm"

local function run(args)
  local ok, _, stderr = wezterm.run_child_process(args)
  if not ok then
    wezterm.log_error("wezterm cli failed: " .. table.concat(args, " ") .. " -- " .. (stderr or ""))
  end
  return ok
end

-- Break the active pane out into its own new tab (tmux `break-pane`).
function M.break_to_tab(_, pane)
  run({ cli, "cli", "move-pane-to-new-tab", "--pane-id", tostring(pane:pane_id()) })
end

-- Pull another pane into the active one as a right-hand split (tmux `join-pane`).
-- Lists every other pane in the window so you can pick which one to absorb; the chosen
-- pane is moved beside the active pane via `split-pane --move-pane-id`.
function M.join_pane(win, pane)
  local target = pane:pane_id()
  local choices = {}
  for _, tab in ipairs(win:mux_window():tabs_with_info()) do
    for _, info in ipairs(tab.tab:panes_with_info()) do
      local id = info.pane:pane_id()
      if id ~= target then
        table.insert(choices, {
          id = tostring(id),
          label = string.format("tab %d  ·  %s  (pane %d)", tab.index + 1, info.pane:get_title(), id),
        })
      end
    end
  end

  if #choices == 0 then
    return
  end

  win:perform_action(
    act.InputSelector({
      title = "Join pane into this one",
      choices = choices,
      action = wezterm.action_callback(function(_, _, id)
        if not id then
          return
        end
        run({ cli, "cli", "split-pane", "--pane-id", tostring(target), "--move-pane-id", id, "--right" })
      end),
    }),
    pane
  )
end

return M
