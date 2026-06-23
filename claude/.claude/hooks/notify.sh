#!/usr/bin/env bash
# Claude Code -> WezTerm native bell + desktop notification.
#
# Wired from ~/.claude/settings.json as a Stop and Notification hook.
# Reads the hook's JSON payload on stdin and returns a `terminalSequence`
# that Claude Code writes to the terminal for us (hooks have no controlling
# tty of their own). The sequence carries:
#   BEL (\a)         -> WezTerm bell event: visual_bell flash + tab highlight
#   OSC 777 ;notify  -> WezTerm desktop notification (needs notification_handling)
#
# Arg $1 selects the message: "waiting" (needs input) or anything else (done).

input=$(cat)
title="Claude Code"

# Skip the notification when this Claude tab is already in view: WezTerm is the
# frontmost app AND its focused pane is the one Claude runs in. Anything else
# (background tab, WezTerm not frontmost) still notifies.
#
# Matching by $WEZTERM_PANE alone is unreliable: when Claude runs under nvim
# (e.g. claudecode.nvim) the inherited pane id can be stale or wrong. So we also
# match by tty -- nvim's controlling tty equals the WezTerm pane's tty_name, and
# nvim is one of our process ancestors, so we walk the ancestry looking for it.
tab_in_view() {
  command -v wezterm >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1

  # WezTerm must be the frontmost macOS app.
  local front
  front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null)
  case "$front" in *WezTerm*) ;; *) return 1 ;; esac

  # Focused pane id of every connected client (one per window).
  local focused_panes
  focused_panes=$(wezterm cli list-clients --format json 2>/dev/null \
    | jq -r '.[].focused_pane_id' 2>/dev/null)
  [ -n "$focused_panes" ] || return 1

  # Fast path: Claude runs directly in a focused pane.
  if [ -n "$WEZTERM_PANE" ] && printf '%s\n' "$focused_panes" | grep -qx "$WEZTERM_PANE"; then
    return 0
  fi

  # ttys of those focused panes (e.g. /dev/ttys017).
  local focused_ttys
  focused_ttys=$(wezterm cli list --format json 2>/dev/null | jq -r \
    --argjson p "[$(printf '%s' "$focused_panes" | paste -sd, -)]" \
    '.[] | select(.pane_id as $id | $p | index($id)) | .tty_name' 2>/dev/null)
  [ -n "$focused_ttys" ] || return 1

  # Walk our ancestry; the host nvim's tty matches the focused pane's tty.
  local pid=$$ ppid tty
  for _ in $(seq 1 20); do
    read -r ppid tty < <(ps -o ppid=,tty= -p "$pid" 2>/dev/null)
    [ -n "$tty" ] && [ "$tty" != "??" ] \
      && printf '%s\n' "$focused_ttys" | grep -qx "/dev/$tty" && return 0
    case "$ppid" in ""|0|1) break ;; esac
    pid=$ppid
  done
  return 1
}

if tab_in_view; then
  jq -n '{suppressOutput: true}'
  exit 0
fi

case "${1:-complete}" in
  waiting) body=$(printf '%s' "$input" | jq -r '.message // "Waiting for your input"') ;;
  *)       body="Task complete" ;;
esac

# \a fires the bell/flash; OSC 777 raises the desktop notification (ST-terminated).
seq=$(printf '\a\033]777;notify;%s;%s\033\\' "$title" "$body")

jq -n --arg seq "$seq" '{terminalSequence: $seq, suppressOutput: true}'
