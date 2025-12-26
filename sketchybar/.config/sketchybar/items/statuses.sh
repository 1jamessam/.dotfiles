#!/bin/bash

COLOR="$PEACH"
wifi=(
  width=35
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
  background.color="$BACKGROUND_1"
  background.border_color="$TRANSPARENT"
  background.drawing=on
)

sketchybar \
  --add alias "Control Center,WiFi" right \
  --rename "Control Center,WiFi" wifi \
  --set wifi "${wifi[@]}" \
  --subscribe wifi wifi_change
sketchybar \
  --add alias "TextInputMenuAgent,Item-0" right \
  --add event input_change "AppleSelectedInputSourcesChangedNitification" \
  --rename "TextInputMenuAgent,Item-0" input_source \
  --set input_source "${input_source[@]}" \
  --subscribe input_source input_change system_woke
sketchybar \
  --add bracket statuses wifi input_source \
  --set statuses "${status_bracket[@]}"
