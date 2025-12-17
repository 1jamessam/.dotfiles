#!/bin/bash

wifi=(
  alias.color=$WHITE
  icon.padding_left=-10
  icon.padding_right=0
  padding_right=0
)

input_source=(
  alias.color="$WHITE"
  padding_left=0
  icon.padding_left=0
  padding_right=0
)

status_bracket=(
  background.color="$BACKGROUND_1"
  background.border_color="$TRANSPARENT"
  background.drawing=on
)

sketchybar --add alias "Control Center,WiFi" right \
  --rename "Control Center,WiFi" wifi \
  --set "${wifi[@]}" \
  --subscribe wifi wifi_change \
  --add alias "TextInputMenuAgent,Item-0" right \
  --add event input_change "AppleSelectedInputSourcesChangedNitification" \
  --rename "TextInputMenuAgent,Item-0" input_source \
  --set "${input_source[@]}" \
  --subscribe input_source input_change system_woke \
  --add bracket statuses wifi input_source \
  --set statuses "${status_bracket[@]}"
