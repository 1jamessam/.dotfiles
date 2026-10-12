#!/bin/bash
# shellcheck disable=SC1091

source "$CONFIG_DIR/colors.sh"

ITEM=pomodoro
BREAK_MIN=${POMODORO_BREAK_MIN:-5}
STATE="${TMPDIR:-/tmp}/sketchybar_pomodoro"
COUNT_FILE="$HOME/.cache/sketchybar_pomodoro_count" # "<date> <sessions done that day>"

# State: <phase: idle|work|break> <running: 0|1> <end epoch if running, else seconds left>
read -r phase running value 2>/dev/null <"$STATE"
phase=${phase:-idle} running=${running:-0} value=${value:-0}
now=$(date +%s)
today=$(date +%F)

# Completed work sessions today; a new day starts back at 0.
read -r count_day count 2>/dev/null <"$COUNT_FILE"
[ "$count_day" = "$today" ] || count=0

save() { echo "$phase $running $value" >"$STATE"; }

start() { # $1 = phase, $2 = seconds
  phase=$1 running=1 value=$((now + $2))
}

notify() {
  osascript -e "display notification \"$1\" with title \"Pomodoro\" sound name \"Glass\"" &
}

close_menu() { sketchybar --set $ITEM popup.drawing=off; }

case "$SENDER:$NAME" in
mouse.exited.global:*) close_menu && exit 0 ;;
mouse.clicked:pomodoro.preset.*)
  close_menu
  start work $((${NAME##*.} * 60))
  ;;
mouse.clicked:pomodoro.reset)
  close_menu
  phase=idle running=0 value=0
  ;;
mouse.clicked:$ITEM)
  if [ "$BUTTON" = "right" ]; then
    sketchybar --set $ITEM popup.drawing=toggle
    exit 0
  elif [ "$phase" = idle ]; then
    start work $((${POMODORO_WORK_MIN:-25} * 60))
  elif [ "$running" = 1 ]; then
    running=0 value=$((value - now)) # pause: store seconds left
  else
    running=1 value=$((now + value)) # resume
  fi
  ;;
esac

if [ "$running" = 1 ]; then
  left=$((value - now))
  if [ "$left" -le 0 ]; then
    if [ "$phase" = work ]; then
      count=$((count + 1))
      mkdir -p "${COUNT_FILE%/*}" && echo "$today $count" >"$COUNT_FILE"
      notify "Work done — take a ${BREAK_MIN}m break"
      start break $((BREAK_MIN * 60))
    else
      notify "Break over — back to work"
      phase=idle running=0 value=0
    fi
    left=$((value - now))
  fi
else
  left=$value
fi
save

case "$phase" in
idle) color=$RED label="" ;;
work) color=$RED label=$(printf '%d:%02d' $((left / 60)) $((left % 60))) ;;
break) color=$GREEN label=$(printf '%d:%02d' $((left / 60)) $((left % 60))) ;;
esac
[ "$phase" != idle ] && [ "$running" = 0 ] && color=$GREY
# Append today's session count, e.g. "18:42 · 3", or just "3" when idle.
if [ "$count" -gt 0 ]; then
  label=${label:+$label · }$count
fi

sketchybar --set $ITEM \
  icon.color="$color" \
  label="$label" \
  label.drawing=$([ -n "$label" ] && echo on || echo off) \
  icon.padding_right=$([ -n "$label" ] && echo 4 || echo 10) \
  update_freq=$([ "$running" = 1 ] && echo 1 || echo 0)
