#!/bin/bash

COLOR="$SAPPHIRE"

sound_level=(
  icon.drawing=off
  # label.font.style=Bold
  label.color="$COLOR"
  # Pin the width, as system.sh does for cpu/memory. Left to size itself, the label
  # changes pixel width on every volume step ("5%" -> "100%"), which resizes the
  # statuses bracket and shifts wifi/battery/sound_icon beside it — the whole right
  # side relayouts on each keypress, which is the blink. Width includes the paddings
  # below: "100%" at Semibold 13.0 is ~37px, plus 0 left + 10 right.
  label.width=47
  # sound_icon is added after sound_level, which puts the icon to its LEFT, so the
  # number anchors left to stay against the icon rather than drifting toward the date.
  label.align=left
  label.padding_left=0
  label.padding_right=10
  script="$PLUGIN_DIR/sound.sh"
  icon.padding_left=-10
)

sound_icon=(
  icon.drawing=on
  icon.padding_left=0
  label.drawing=off
  alias.color="$COLOR"
)

status_bracket=(
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
)

sketchybar \
  --add item sound_level right \
  --set sound_level "${sound_level[@]}" \
  --subscribe sound_level volume_change

sketchybar \
  --add alias "Control Center,Sound" right \
  --rename "Control Center,Sound" sound_icon \
  --set sound_icon "${sound_icon[@]}"

# sketchybar \
#   --add bracket sound sound_level sound_icon \
#   --set sound "${status_bracket[@]}"
