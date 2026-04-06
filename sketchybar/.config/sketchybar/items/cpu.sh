#!/bin/bash

cpu=(
  icon.drawing=off
  padding_left=8
  label.color="$WHITE"
  # background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
  graph.color="$GREEN"
  graph.fill_color="0x40a6d189"
  graph.line_width=1.5
  width=100
  label.width=40
  label.align=right
  script="$PLUGIN_DIR/cpu.sh"
  update_freq=5
  updates=on
  icon.padding_left=4
  label.padding_right=4
  padding_left=2
  padding_right=10
)

status_bracket=(
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
)

sketchybar \
  --add graph cpu right 60 \
  --set cpu "${cpu[@]}" \
  --add bracket statuses cpu wifi battery sound_level sound_icon \
  --set statuses "${status_bracket[@]}"
