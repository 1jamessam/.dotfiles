#!/bin/bash

music=(
  script="$PLUGIN_DIR/youtube-music.sh"
  click_script="curl -s -X POST 0.0.0.0:26538/api/v1/toggle-play && $PLUGIN_DIR/youtube-music.sh"
  label.padding_right=8
  label.font="Hack Nerd Font:Bold:17.0"
  padding_right=0
  icon=􁁒
  # Pinned it to the primary display since my other monitor is in vertical layout
  # display=1
  label="Loading…"
  background.image.scale=0.9
  background.image.corner_radius=8
  background.image.border_color="$TRANSPARENT"
  background.color="$TRANSPARENT"
  icon.padding_left=36
  icon.padding_right=8
  label.align=left
  update_freq=10
  label.max_chars=40
  scroll_texts=on
)

music_artwork=(
  click_script="curl -s -X POST 0.0.0.0:26538/api/v1/toggle-play && $PLUGIN_DIR/youtube-music.sh"
  label.padding_right=8
  padding_right=16
  display=1
  label=""
  width=40
  background.image.scale=0.07
  background.image.corner_radius=8
  background.image.border_color="$TRANSPARENT"
  background.color="$TRANSPARENT"
)

sketchybar \
  --add item music center \
  --set music "${music[@]}"

sketchybar \
  --add item music-artwork center \
  --set music-artwork "${music_artwork[@]}"
