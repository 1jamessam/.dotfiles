#!/bin/bash

battery=(
  label.drawing=on
  alias.color="$GREEN"
  script="$PLUGIN_DIR/battery.sh"
  icon.padding_left=0
  label.padding_right=0
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
  update_freq=120
  updates=on
)

sketchybar \
  --add alias "Control Center,Battery" right \
  --rename "Control Center,Battery" battery \
  --set battery "${battery[@]}" \
  --subscribe battery power_source_change
