#!/bin/bash
# shellcheck disable=SC1091

source "$CONFIG_DIR/colors.sh"

ITEM=pomodoro
BREAK_MIN=${POMODORO_BREAK_MIN:-5}
STATE="${TMPDIR:-/tmp}/sketchybar_pomodoro"
# One line per work session: "<end epoch> <focused seconds> <completed 0|1>".
# The only record of history; every count and total is derived from it.
LOG="$HOME/.local/share/sketchybar/pomodoro.log"

# State: <phase: idle|work|break> <running: 0|1> <end epoch if running, else seconds left>
#        <length of the current session in seconds>
read -r phase running value length 2>/dev/null <"$STATE"
phase=${phase:-idle} running=${running:-0} value=${value:-0} length=${length:-0}
now=$(date +%s)
day_start=$(date -v0H -v0M -v0S +%s)
week_start=$(date -v-mon -v0H -v0M -v0S +%s) # Monday 00:00

save() { echo "$phase $running $value $length" >"$STATE"; }

start() { # $1 = phase, $2 = seconds
  phase=$1 running=1 value=$((now + $2)) length=$2
}

seconds_left() {
  if [ "$running" = 1 ]; then echo $((value - now)); else echo "$value"; fi
}

log_session() { # $1 = focused seconds, $2 = completed 0|1
  mkdir -p "${LOG%/*}" && echo "$now $1 $2" >>"$LOG"
}

# Log the time worked so far when a work session is abandoned; under a minute is a mis-click.
log_abandoned() {
  [ "$phase" = work ] || return
  local worked=$((length - $(seconds_left)))
  [ "$worked" -ge 60 ] && log_session "$worked" 0
}

# Prints "<focused seconds> <completed sessions>" for log lines ending at or after $1.
stats_since() {
  [ -f "$LOG" ] || { echo "0 0" && return; }
  awk -v since="$1" '$1 >= since { s += $2; n += $3 } END { print s + 0, n + 0 }' "$LOG"
}

fmt_duration() {
  local h=$(($1 / 3600)) m=$(($1 % 3600 / 60))
  if [ "$h" -gt 0 ]; then echo "${h}h ${m}m"; else echo "${m}m"; fi
}

stat_row() { # $1 = title, $2 = since epoch
  local secs n
  read -r secs n < <(stats_since "$2")
  echo "$1   $(fmt_duration "$secs") · $n session$([ "$n" = 1 ] || echo s)"
}

notify() {
  osascript -e "display notification \"$1\" with title \"Pomodoro\" sound name \"Glass\"" &
}

close_menu() { sketchybar --set $ITEM popup.drawing=off; }

open_menu() {
  sketchybar --set pomodoro.stat.today label="$(stat_row Today "$day_start")" \
    --set pomodoro.stat.week label="$(stat_row 'This week' "$week_start")" \
    --set $ITEM popup.drawing=on
}

# Hover over the item or its menu: the latest enter/exit writes a fresh token, and a
# delayed action only fires if no newer hover event replaced that token in the meantime.
# Entering opens after OPEN_DELAY; leaving closes after a short grace period, so moving
# from the item into its menu (or between menu rows) doesn't close it.
OPEN_DELAY=1
CLOSE_DELAY=0.4
HOVER="$STATE.hover"
after_hover() { # $1 = delay, $2 = command; runs it only if hover hasn't changed by then
  local token="$SENDER $RANDOM$RANDOM"
  echo "$token" >"$HOVER"
  (sleep "$1" && [ "$(cat "$HOVER")" = "$token" ] && $2) >/dev/null 2>&1 &
}

case "$SENDER:$NAME" in
mouse.exited.global:*) echo >"$HOVER" && close_menu && exit 0 ;;
mouse.entered:*) after_hover $OPEN_DELAY open_menu && exit 0 ;;
mouse.exited:*) after_hover $CLOSE_DELAY close_menu && exit 0 ;;
mouse.clicked:pomodoro.preset.*)
  close_menu
  log_abandoned
  start work $((${NAME##*.} * 60))
  ;;
mouse.clicked:pomodoro.reset)
  close_menu
  log_abandoned
  phase=idle running=0 value=0 length=0
  ;;
mouse.clicked:$ITEM)
  if [ "$BUTTON" = "right" ]; then
    exit 0 # the menu opens on hover now
  elif [ "$phase" = idle ]; then
    start work $((${POMODORO_WORK_MIN:-25} * 60))
  elif [ "$running" = 1 ]; then
    running=0 value=$((value - now)) # pause: store seconds left
  else
    running=1 value=$((now + value)) # resume
  fi
  ;;
esac

if [ "$running" = 1 ] && [ $((value - now)) -le 0 ]; then
  if [ "$phase" = work ]; then
    log_session "$length" 1
    notify "Work done — take a ${BREAK_MIN}m break"
    start break $((BREAK_MIN * 60))
  else
    notify "Break over — back to work"
    phase=idle running=0 value=0 length=0
  fi
fi
left=$(seconds_left)
save

case "$phase" in
idle) color=$RED label="" ;;
work) color=$RED label=$(printf '%d:%02d' $((left / 60)) $((left % 60))) ;;
break) color=$GREEN label=$(printf '%d:%02d' $((left / 60)) $((left % 60))) ;;
esac
[ "$phase" != idle ] && [ "$running" = 0 ] && color=$GREY
# Append today's session count, e.g. "18:42 · 3", or just "3" when idle.
read -r _ count < <(stats_since "$day_start")
if [ "$count" -gt 0 ]; then
  label=${label:+$label · }$count
fi

sketchybar --set $ITEM \
  icon.color="$color" \
  label="$label" \
  label.drawing=$([ -n "$label" ] && echo on || echo off) \
  icon.padding_right=$([ -n "$label" ] && echo 4 || echo 10) \
  update_freq=$([ "$running" = 1 ] && echo 1 || echo 0)
