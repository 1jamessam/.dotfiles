#!/bin/bash

COLOR="$PEACH"
wifi=(
  alias.color="$COLOR"
  # background.color="$WHITE"
  label.drawing=off
  icon.drawing=off
  padding_right=0
  icon.padding_left=0
  icon.padding_right=0
  label.padding_left=0
  label.padding_right=0
)

input_source=(
  width=45
  alias.color="$COLOR"
  label.drawing=off
  icon.drawing=off
)

status_bracket=(
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
)

sketchybar \
  --add alias "Control Center,WiFi" right \
  --rename "Control Center,WiFi" wifi \
  --set wifi "${wifi[@]}" \
  --subscribe wifi wifi_change

# sketchybar \
#   --add alias "TextInputMenuAgent,Item-0" right \
#   --add event input_change "AppleSelectedInputSourcesChangedNitification" \
#   --rename "TextInputMenuAgent,Item-0" input_source \
#   --set input_source "${input_source[@]}" \
#   --subscribe input_source input_change system_woke

## bracket is created in cpu.sh (sourced after this file)

# sketchybar --query default_menu_items
