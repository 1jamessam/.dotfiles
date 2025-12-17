#!/bin/bash

wifi=(
  alias.color=$WHITE
)

sketchybar --add alias "Control Center,WiFi" right \
  --rename "Control Center,WiFi" wifi \
  --set "${wifi[@]}" \
  --subscribe wifi wifi_change

input_source=(
  alias.color="$WHITE"
)
sketchybar --add alias "TextInputMenuAgent,Item-0" right \
  --add event input_change "AppleSelectedInputSourcesChangedNitification" \
  --rename "TextInputMenuAgent,Item-0" input_source \
  --set "${input_source[@]}" \
  --subscribe input_source input_change system_woke

status_bracket=(
  background.color="$BACKGROUND_1"
  background.border_color="$TRANSPARENT"
  background.drawing=on
)

sketchybar --add bracket statuses wifi input_source \
  --set statuses "${status_bracket[@]}"
