#!/bin/bash

COLOR="$SAPPHIRE"

sound_level=(
  icon.drawing=off
  # label.font.style=Bold
  label.color="$COLOR"
  label.padding_left=0
  label.padding_right=10
  script="$PLUGIN_DIR/sound.sh"
)

sound_icon=(
  # icon.drawing=off
  icon.padding_left=0
  label.drawing=off
  alias.color="$COLOR"
)

status_bracket=(
  background.color="$BACKGROUND_1"
  background.border_color="$TRANSPARENT"
  background.height=30
  background.drawing=on
  background.padding_left=20
  background.padding_right=10
  padding_left=20
  padding_right=10
)

sketchybar \
  --add item sound_level right \
  --set sound_level "${sound_level[@]}" \
  --subscribe sound_level volume_change
sketchybar \
  --add alias "Control Center,Sound" right \
  --rename "Control Center,Sound" sound_icon \
  --set sound_icon "${sound_icon[@]}"
sketchybar \
  --add bracket sound sound_level sound_icon \
  --set sound "${status_bracket[@]}"
