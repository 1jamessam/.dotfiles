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
tab_in_view() {
  [ -n "$WEZTERM_PANE" ] || return 1
  command -v wezterm >/dev/null 2>&1 || return 1
  local front
  front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null)
  case "$front" in *WezTerm*) ;; *) return 1 ;; esac
  wezterm cli list-clients --format json 2>/dev/null \
    | jq -e --argjson p "$WEZTERM_PANE" 'any(.[]; .focused_pane_id == $p)' >/dev/null 2>&1
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
