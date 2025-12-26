#!/bin/bash

calendar=(
  icon=cal
  icon.font="$FONT:Bold:14.0"
  icon.padding_left=15
  icon.padding_right=10
  label.align=right
  label.font.size=16
  label.padding_right=20
  # label.font.style=Regular
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  background.color="$BG0"
  background.border_color="$TRANSPARENT"
  background.height=30
)

sketchybar --add item calendar right \
  --set calendar "${calendar[@]}" \
  --subscribe calendar system_woke
