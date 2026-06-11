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

case "${1:-complete}" in
  waiting) body=$(printf '%s' "$input" | jq -r '.message // "Waiting for your input"') ;;
  *)       body="Task complete" ;;
esac

# \a fires the bell/flash; OSC 777 raises the desktop notification (ST-terminated).
seq=$(printf '\a\033]777;notify;%s;%s\033\\' "$title" "$body")

jq -n --arg seq "$seq" '{terminalSequence: $seq, suppressOutput: true}'
