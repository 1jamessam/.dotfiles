#!/bin/bash

COLOR="$PEACH"
wifi=(
  width=45
  alias.color="$COLOR"
  label.drawing=off
  icon.drawing=off
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

sketchybar \
  --add bracket statuses wifi battery sound_level sound_icon calendar \
  --set statuses "${status_bracket[@]}"

# sketchybar --query default_menu_items
