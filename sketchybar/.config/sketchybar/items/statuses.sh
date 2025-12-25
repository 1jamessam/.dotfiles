#!/bin/bash

# sketchybar --set wifi click_script="osascript -e 'tell application \"System Events\" to tell process \"Control Center\" to perform action \"AXPress\" of menu bar item 2 of menu bar 1'"
wifi=(
  alias.color="$WHITE"
  click_script
)

input_source=(
  alias.color="$WHITE"
)

status_bracket=(
  # width=20
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
