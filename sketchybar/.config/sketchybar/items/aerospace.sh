#!/bin/bash

INDEX=0
ALL_WORKSPACES=$(aerospace list-workspaces --all)

space=(
  # background.color=0x44ffffff
  background.color=0x44cad3f5
  background.corner_radius=10
  background.padding_left=4
  background.padding_right=4
  background.drawing=off
  label.padding_left=8
  label.padding_right=8
  label.font="sketchybar-app-font:Regular:16.0"
  icon.drawing=off
)

for sid in $ALL_WORKSPACES; do
  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" aerospace_workspace_change front_app_switched \
    --set space."$sid" "${space[@]}" \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"

  INDEX=$((INDEX + 1))
done
