#!/bin/bash

front_app=(
  label.font="$FONT:Bold:16.0"
  label.padding_left=5
  label.drawing=off
  icon.background.drawing=on
  display=active
  script="$PLUGIN_DIR/front_app.sh"
  click_script="open -a 'Mission Control'"
  padding_right=10
  padding_left=10
)
chevron=(
  icon=
  icon.font="Hack Nerd Font:Bold:17.0"
  label.drawing=off
)
sketchybar --add item chevron left --set chevron "${chevron[@]}"

sketchybar --add item front_app left \
  --set front_app "${front_app[@]}" \
  --subscribe front_app front_app_switched
