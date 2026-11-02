#!/bin/bash

# Reads macOS Now Playing, so it follows whichever player is active: Kaset,
# YouTube Music in Safari, Spotify, etc. --no-artwork keeps the per-tick
# payload small; artwork is fetched separately only when the song changes.
IFS=$'\t' read -r PLAYING CURRENT_SONG <<< "$(media-control get --no-artwork 2>/dev/null \
  | jq -r 'select(.title) | [.playing, .title + (if .artist then " - " + .artist else "" end)] | @tsv')"

if [ -z "$CURRENT_SONG" ]; then
  sketchybar --set "$NAME" drawing=off --set "$NAME"-artwork drawing=off
  exit 0
fi

ICON=􀊄
[ "$PLAYING" = true ] && ICON=􁁒

sketchybar --set "$NAME" label="$CURRENT_SONG" icon="$ICON" drawing=on \
  --set "$NAME"-artwork drawing=on

CACHE_FILE="$TMPDIR/sketchybar_music_song"
[ "$CURRENT_SONG" = "$(cat "$CACHE_FILE" 2>/dev/null)" ] && exit 0

# Artwork arrives inline as base64 (sometimes TIFF despite the jpeg mime type),
# so decode it and normalize to PNG. Key the file on the song: sketchybar
# won't re-read an image whose path is unchanged.
ARTWORK_LOCATION="$TMPDIR/sketchybar_music_artwork_$(printf '%s' "$CURRENT_SONG" | md5 -q).png"
RAW="$TMPDIR/sketchybar_music_artwork_raw"
rm -f "$TMPDIR"/sketchybar_music_artwork_*.png
media-control get | jq -r '.artworkData // empty' | base64 -D > "$RAW" 2>/dev/null
[ -s "$RAW" ] || exit 0
sips -s format png "$RAW" --out "$ARTWORK_LOCATION" >/dev/null 2>&1 || exit 0
rm -f "$RAW"

# Artwork is square album art for library songs but a 16:9 thumbnail for
# videos, so derive the scale from the image instead of hardcoding it. Scale
# off the height so both shapes stand equally tall; 40 is the ceiling, since
# anything over the bar's own 44pt height gets clipped. The item width then
# has to follow the scaled width, or a 16:9 thumbnail spills onto the label.
read -r SCALE ITEM_WIDTH <<< "$(sips -g pixelWidth -g pixelHeight "$ARTWORK_LOCATION" \
  | awk '/pixelWidth/ { w = $2 } /pixelHeight/ { h = $2 }
         END { if (w && h) printf "%.4f %d", 40 / h, w * 40 / h + 0.5 }')"
[ -n "$SCALE" ] || exit 0

sketchybar --set "$NAME"-artwork background.image="$ARTWORK_LOCATION" \
  background.image.scale="$SCALE" width="$ITEM_WIDTH"

# Only cache once the artwork actually landed, so a failure retries next tick.
echo "$CURRENT_SONG" > "$CACHE_FILE"
