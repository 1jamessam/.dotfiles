#!/bin/bash

battery=(
  label.drawing=on
  alias.color="$GREEN"
  script="$PLUGIN_DIR/battery.sh"
  icon.padding_left=5
  label.padding_right=15
  background.color="$BG1"
  background.height=30
  background.border_color="$TRANSPARENT"
  # background.padding_left=10
  # background.padding_right=10
  update_freq=120
  updates=on
)

sketchybar \
  --add alias "Control Center,Battery" right \
  --rename "Control Center,Battery" battery \
  --set battery "${battery[@]}" \
  --subscribe battery power_source_change
