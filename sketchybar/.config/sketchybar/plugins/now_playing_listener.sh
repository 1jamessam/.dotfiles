#!/bin/bash

# Fires now_playing_change on every Now Playing update, so the music item is
# pushed instead of polled. Started (and restarted on reload) by items/music.sh.
PIDFILE="$TMPDIR/sketchybar_now_playing_listener.pid"

# Stop the previous listener and its pipeline children so reloads don't stack.
# The pidfile (not pkill -f) avoids killing unrelated processes that merely
# mention this script, e.g. an editor that has it open.
if OLD=$(cat "$PIDFILE" 2>/dev/null) && [ "$OLD" != "$$" ]; then
  pkill -P "$OLD" 2>/dev/null
  kill "$OLD" 2>/dev/null
fi
echo $$ > "$PIDFILE"

media-control stream --no-artwork --debounce=200 \
  | while read -r _; do sketchybar --trigger now_playing_change; done
