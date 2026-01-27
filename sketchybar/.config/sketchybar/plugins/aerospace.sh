#!/usr/bin/env bash

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

update_workspace_icon() {
  local workspace_id=$1

  local APP_ICONS
  APP_ICONS=$(aerospace list-windows --workspace "$workspace_id" |
    awk -F '|' '{print $2}' |
    while read -r app_name; do
      "$CONFIG_DIR/icon_map.sh" "$app_name"
    done | tr '\n' ' ' | sed 's/ *$//')

  if [ -z "$APP_ICONS" ]; then
    APP_ICONS="⏺︎"
  fi

  common=(
    label="$APP_ICONS"
    icon="$workspace_id"
  )
  if [ "$workspace_id" == "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" "${common[@]}" background.drawing=on
  else
    sketchybar --set "$NAME" "${common[@]}" background.drawing=off
  fi
}

update_workspace_icon "$1"
