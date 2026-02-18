#!/bin/bash

ALL_WORKSPACES=$(aerospace list-workspaces --all)

space=(
  background.color=0x40ffffff
  background.corner_radius=8
  background.height=26
  background.drawing=off
  label.padding_left=6
  label.padding_right=8
  label.font="sketchybar-app-font:Regular:16.0"
  label.color="$WHITE"
  icon.drawing=on
  icon.padding_left=8
  icon.padding_right=0
  icon.font="$FONT:Bold:13.0"
  icon.color="$WHITE"
)

sketchybar --add event aerospace_workspace_change

SPACE_ITEMS=()
for sid in $ALL_WORKSPACES; do
  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" aerospace_workspace_change front_app_switched \
    --set space."$sid" "${space[@]}" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
  SPACE_ITEMS+=(space."$sid")
done

# Group workspaces in an island
sketchybar --add bracket spaces "${SPACE_ITEMS[@]}" \
  --set spaces background.color="$BASE" \
               background.corner_radius=10 \
               background.height=30 \
               background.drawing=on
