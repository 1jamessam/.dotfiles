#!/usr/bin/env bash
# Shared state + highlight styling for the aerospace workspace items. Sourced by both
# items/aerospace.sh (bar setup) and plugins/aerospace.sh (event handler) so the two
# stay in sync automatically. Requires colors.sh to be sourced first (for the palette).

# Cache/state files live OUTSIDE $CONFIG_DIR: sketchybar's --hotload reloads the whole
# bar on any change in the config dir, so writing caches there would make every
# workspace switch trigger a reload (flicker). Use tmp.
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_aerospace"

# The aerospace CLI blocks indefinitely when the daemon is busy mid-switch rather than
# erroring out, and nothing reaps the stuck child — they pile up one per invocation
# (seven were found alive across two weeks). macOS ships no coreutils `timeout`, so
# bound the call here instead of taking a Brewfile dep. On timeout the child is killed
# and nothing is printed, so callers' existing empty-output guards cover it.
# Callers can shorten it by setting AEROSPACE_TIMEOUT; resolved per call so unsetting
# it again falls back to the default rather than passing an empty value to sleep.
#
# Output goes via a temp file, never straight into the caller's $(...) pipe. Writing to
# the pipe would mean the timeout only unblocks us if the killed process was the last
# holder of that pipe — any grandchild outliving it keeps the substitution hanging for
# the full original duration, which is the exact failure this is meant to bound.
aerospace_q() {
  local t="${AEROSPACE_TIMEOUT:-2}" rc out
  out=$(mktemp "${TMPDIR:-/tmp}/aerospace_q.XXXXXX") || return 1

  aerospace "$@" >"$out" 2>/dev/null &
  local pid=$!
  ( sleep "$t"; kill -9 "$pid" 2>/dev/null ) >/dev/null 2>&1 &
  local watchdog=$!

  wait "$pid" 2>/dev/null; rc=$?
  kill "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null

  # Suppress partial output from a killed call so callers see "empty" (their existing
  # not-ready guard) rather than a truncated workspace/window list they'd act on.
  [ "$rc" -eq 0 ] && cat "$out"
  rm -f "$out"
  return "$rc"
}

# Styling for the focused vs unfocused workspace item.
aerospace_focused=(background.drawing=on background.border_width=0
  background.color="$LAVENDER" icon.color="$BLACK" label.color="$BLACK")
aerospace_unfocused=(background.drawing=off background.border_width=0
  background.color="$BASE" icon.color="$GREY" label.color="$GREY")
