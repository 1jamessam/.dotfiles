#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Source only the icon_map function
eval "$(sed -n '/^function icon_map/,/^}/p' "$CONFIG_DIR/icon_map.sh")"

if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

# Build icon strings per workspace using simple variables
ALL_WINDOWS=$(aerospace list-windows --all --format '%{app-name}|%{workspace}')
ALL_WORKSPACES=$(aerospace list-workspaces --all)

args=()
for sid in $ALL_WORKSPACES; do
  icons=""
  while IFS='|' read -r app_name workspace_id; do
    app_name="${app_name## }"; app_name="${app_name%% }"
    workspace_id="${workspace_id## }"; workspace_id="${workspace_id%% }"
    if [ "$workspace_id" = "$sid" ]; then
      icon_map "$app_name"
      icons+="$icon_result"
    fi
  done <<< "$ALL_WINDOWS"

  if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
    args+=(--set space."$sid"
      icon="$sid" label="$icons"
      background.drawing=on background.border_width=0
      --animate tanh 15 --set space."$sid"
      background.color="$LAVENDER" icon.color="$BLACK" label.color="$BLACK")
  else
    args+=(--set space."$sid"
      icon="$sid" label="$icons"
      background.border_width=0
      --animate tanh 15 --set space."$sid"
      background.color="$BASE" icon.color="$GREY" label.color="$GREY"
      background.drawing=off)
  fi
done

sketchybar "${args[@]}"
