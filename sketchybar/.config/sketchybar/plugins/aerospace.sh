#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

update_workspace_icon() {
  local workspace_id=$1

  local APP_ICONS
  APP_ICONS=$(aerospace list-windows --workspace "$workspace_id" |
    awk -F '|' '{print $2}' |
    while read -r app_name; do
      "$CONFIG_DIR/icon_map.sh" "$app_name"
    done | tr -d '\n')

  common=(
    label="$APP_ICONS"
    icon="$workspace_id"
  )
  if [ "$workspace_id" == "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" "${common[@]}" \
      background.drawing=on \
      background.color="$LAVENDER" \
      background.border_width=0 \
      icon.color="$BLACK" \
      label.color="$BLACK"
  else
    sketchybar --set "$NAME" "${common[@]}" \
      background.drawing=off \
      background.border_width=0 \
      icon.color="$GREY" \
      label.color="$GREY"
  fi
}

update_workspace_icon "$1"
