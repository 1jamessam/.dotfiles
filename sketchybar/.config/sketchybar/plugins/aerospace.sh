#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Cache/state files MUST live outside $CONFIG_DIR: sketchybar's `--hotload true`
# reloads the whole bar on any file change in the config dir, so writing caches
# there would make every workspace switch trigger a reload (flicker). Use tmp.
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_aerospace"
mkdir -p "$STATE_DIR"

[ -z "$FOCUSED_WORKSPACE" ] && FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Fast path: a workspace switch only moves the highlight — windows don't move, so
# the per-workspace app icons are unchanged. Highlight the new workspace and
# un-highlight the previous one (two items, no aerospace calls) so the bar tracks
# the switch instantly. Previous focus is cached in $STATE_DIR/focused, seeded at
# load by items/aerospace.sh.
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  [ -z "$FOCUSED_WORKSPACE" ] && exit 0
  PREV=$(cat "$STATE_DIR/focused" 2>/dev/null)
  [ "$PREV" = "$FOCUSED_WORKSPACE" ] && exit 0
  printf '%s' "$FOCUSED_WORKSPACE" > "$STATE_DIR/focused"

  focused=(background.drawing=on background.border_width=0
    background.color="$LAVENDER" icon.color="$BLACK" label.color="$BLACK")
  unfocused=(background.drawing=off background.border_width=0
    background.color="$BASE" icon.color="$GREY" label.color="$GREY")

  args=(--set space."$FOCUSED_WORKSPACE" "${focused[@]}")
  [ -n "$PREV" ] && args+=(--set space."$PREV" "${unfocused[@]}")
  sketchybar "${args[@]}"
  exit 0
fi

# Icon path (front_app_switched / startup): refresh per-workspace app icons.
# front_app_switched can fire several times per switch; an atomic mkdir lock keeps
# a single rebuild running so concurrent runs don't race on the cache.
LOCK="$STATE_DIR/icons.lock"
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

source "$CONFIG_DIR/icon_map.sh"

ALL_WINDOWS=$(aerospace list-windows --all --format '%{app-name}|%{workspace}')
ALL_WORKSPACES=$(aerospace list-workspaces --all)
[ -z "$ALL_WORKSPACES" ] && exit 0  # daemon busy mid-switch; leave the bar untouched

# Touch only the label (app icons), never the highlight (owned by the fast path),
# and diff against the last render so unchanged workspaces aren't repainted. On a
# plain switch nothing changed, so nothing is set and the bar doesn't flicker.
CACHE="$STATE_DIR/labels"
args=()
newcache=""
for sid in $ALL_WORKSPACES; do
  icons=""
  while IFS='|' read -r app_name workspace_id; do
    app_name="${app_name## }"; app_name="${app_name%% }"
    workspace_id="${workspace_id## }"; workspace_id="${workspace_id%% }"
    [ "$workspace_id" = "$sid" ] && { icon_map "$app_name"; icons+="$icon_result"; }
  done <<< "$ALL_WINDOWS"

  newcache+="$sid|$icons"$'\n'
  prev=$(grep "^$sid|" "$CACHE" 2>/dev/null); prev="${prev#*|}"
  [ "$icons" != "$prev" ] && args+=(--set space."$sid" label="$icons")
done

# Atomic write (temp + mv) so a concurrent reader never sees a truncated cache.
printf '%s' "$newcache" > "$CACHE.$$" && mv -f "$CACHE.$$" "$CACHE"

[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
