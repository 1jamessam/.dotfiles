#!/bin/bash

battery=(
  script="$PLUGIN_DIR/battery.sh"
  icon.font="$FONT:Regular:19.0"
  icon.padding_left=10
  icon.padding_right=10
  label.padding_right=10
  label.drawing=on
  update_freq=120
  updates=on
  background.color="$BG0"
)

sketchybar --add item battery right \
  --set battery "${battery[@]}" \
  --subscribe battery power_source_change system_woke
