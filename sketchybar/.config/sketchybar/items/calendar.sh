#!/bin/bash

COLOR="$MAUVE"
calendar=(
  icon=cal
  icon.color="$COLOR"
  icon.font="$FONT:Bold:13.0"
  icon.padding_left=10
  icon.padding_right=2
  label.color="$WHITE"
  label.font="$FONT:Bold:13.0"
  label.padding_right=10
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
)

sketchybar --add item calendar right \
  --set calendar "${calendar[@]}" \
  --subscribe calendar system_woke
