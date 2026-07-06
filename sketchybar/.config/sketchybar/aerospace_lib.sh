#!/usr/bin/env bash
# Shared state + highlight styling for the aerospace workspace items. Sourced by both
# items/aerospace.sh (bar setup) and plugins/aerospace.sh (event handler) so the two
# stay in sync automatically. Requires colors.sh to be sourced first (for the palette).

# Cache/state files live OUTSIDE $CONFIG_DIR: sketchybar's --hotload reloads the whole
# bar on any change in the config dir, so writing caches there would make every
# workspace switch trigger a reload (flicker). Use tmp.
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_aerospace"

# Styling for the focused vs unfocused workspace item.
aerospace_focused=(background.drawing=on background.border_width=0
  background.color="$LAVENDER" icon.color="$BLACK" label.color="$BLACK")
aerospace_unfocused=(background.drawing=off background.border_width=0
  background.color="$BASE" icon.color="$GREY" label.color="$GREY")
