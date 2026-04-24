#!/bin/bash

SONG_INFO=$(curl -s 0.0.0.0:26538/api/v1/song-info)

IFS=$'\t' read -r PAUSED CURRENT_SONG <<< "$(echo "$SONG_INFO" | jq -r '[.isPaused, (.title + " - " + .artist)] | @tsv')"

if [ "$PAUSED" = true ]; then
  ICON=􀊄
else
  ICON=􁁒
fi

sketchybar --set "$NAME" label="$CURRENT_SONG" icon="$ICON" drawing=on

CACHE_FILE="$TMPDIR/sketchybar_music_song"
PREV_SONG=""
[ -f "$CACHE_FILE" ] && PREV_SONG=$(cat "$CACHE_FILE")

if [ "$CURRENT_SONG" != "$PREV_SONG" ]; then
  ARTWORK="$(echo "$SONG_INFO" | jq -r '.imageSrc')"
  ARTWORK_LOCATION="$(curl -O --output-dir "$TMPDIR" -s --remote-name -w "%{filename_effective}" "$ARTWORK")"
  sketchybar --set "$NAME"-artwork background.image="$ARTWORK_LOCATION"
  echo "$CURRENT_SONG" > "$CACHE_FILE"
fi
