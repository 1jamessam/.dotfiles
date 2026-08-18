#!/bin/bash

# Guard on the process: `tell application "Kaset"` would launch it otherwise.
if ! pgrep -x Kaset >/dev/null; then
  sketchybar --set "$NAME" drawing=off --set "$NAME"-artwork drawing=off
  exit 0
fi

PLAYER_INFO=$(osascript -e 'tell application "Kaset" to get player info')

IFS=$'\t' read -r PAUSED CURRENT_SONG VIDEO_ID <<< "$(echo "$PLAYER_INFO" | jq -r '[
  .isPaused,
  (.currentTrack | if . then .name + " - " + .artist else "" end),
  (.currentTrack.videoId // "")
] | @tsv')"

if [ -z "$CURRENT_SONG" ]; then
  sketchybar --set "$NAME" drawing=off --set "$NAME"-artwork drawing=off
  exit 0
fi

if [ "$PAUSED" = true ]; then
  ICON=􀊄
else
  ICON=􁁒
fi

sketchybar --set "$NAME" label="$CURRENT_SONG" icon="$ICON" drawing=on \
  --set "$NAME"-artwork drawing=on

CACHE_FILE="$TMPDIR/sketchybar_music_song"
PREV_SONG=""
[ -f "$CACHE_FILE" ] && PREV_SONG=$(cat "$CACHE_FILE")

[ "$CURRENT_SONG" = "$PREV_SONG" ] && exit 0

# `get player info` reports artworkURL as a bare https://music.youtube.com/
# placeholder, so take the real thumbnail from the queue, matched on video id.
ARTWORK=$(osascript -e 'tell application "Kaset" to get play queue' \
  | jq -r --arg id "$VIDEO_ID" 'first(.tracks[] | select(.videoId == $id) | .artworkURL) // ""')
[ -n "$ARTWORK" ] || exit 0

# Key the file on the video id: every Kaset artwork URL ends in the same
# hq720.jpg, and sketchybar won't re-read an image whose path is unchanged.
ARTWORK_LOCATION="$TMPDIR/sketchybar_music_artwork_$VIDEO_ID.jpg"
rm -f "$TMPDIR"/sketchybar_music_artwork_*.jpg
curl -s -o "$ARTWORK_LOCATION" "$ARTWORK"

# Artwork is square album art for library songs but a 16:9 thumbnail for
# videos, so derive the scale from the image instead of hardcoding it. Scale
# off the height so both shapes stand equally tall; 40 is the ceiling, since
# anything over the bar's own 44pt height gets clipped. The item width then
# has to follow the scaled width, or a 16:9 thumbnail spills onto the label.
read -r ARTWORK_WIDTH ARTWORK_HEIGHT <<< "$(sips -g pixelWidth -g pixelHeight "$ARTWORK_LOCATION" \
  | awk '/pixelWidth/ { w = $2 } /pixelHeight/ { h = $2 } END { print w, h }')"
[ -n "$ARTWORK_WIDTH" ] && [ -n "$ARTWORK_HEIGHT" ] || exit 0
SCALE=$(awk -v h="$ARTWORK_HEIGHT" 'BEGIN { printf "%.4f", 40 / h }')
ITEM_WIDTH=$(awk -v w="$ARTWORK_WIDTH" -v s="$SCALE" 'BEGIN { printf "%d", w * s + 0.5 }')

sketchybar --set "$NAME"-artwork background.image="$ARTWORK_LOCATION" \
  background.image.scale="$SCALE" width="$ITEM_WIDTH"

# Only cache once the artwork actually landed, so a failure retries next tick.
echo "$CURRENT_SONG" > "$CACHE_FILE"
