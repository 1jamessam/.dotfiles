#!/bin/bash

ALL_WORKSPACES=$(aerospace list-workspaces --all)

space=(
  # background.color=0x40ffffff
  background.color="$BASE"
  background.corner_radius=8
  background.height=26
  background.drawing=off
  label.padding_left=8
  label.padding_right=8
  label.font="sketchybar-app-font:Regular:18.0"
  label.color="$WHITE"
  icon.drawing=on
  icon.padding_left=8
  icon.padding_right=4
  icon.font.family="$FONT"
  icon.font.style=Bold
  icon.font.size=16.0
  icon.color="$WHITE"
)

sketchybar --add event aerospace_workspace_change

SPACE_ITEMS=()
FIRST=true
for sid in $ALL_WORKSPACES; do
  sketchybar --add item space."$sid" left \
    --set space."$sid" "${space[@]}" \
    click_script="aerospace workspace $sid"

  # Only the first space item runs the script for all spaces
  if $FIRST; then
    sketchybar --set space."$sid" \
      updates=on \
      script="$CONFIG_DIR/plugins/aerospace.sh" \
      --subscribe space."$sid" aerospace_workspace_change front_app_switched
    FIRST=false
  fi

  SPACE_ITEMS+=(space."$sid")
done

# Group workspaces in an island
sketchybar --add bracket spaces "${SPACE_ITEMS[@]}" \
  --set spaces background.color="$BASE" \
  background.corner_radius=10 \
  background.height=30 \
  background.drawing=on
