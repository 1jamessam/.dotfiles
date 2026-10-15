#!/bin/bash
# shellcheck disable=SC1091

source "$CONFIG_DIR/colors.sh"

ITEM=pomodoro
BREAK_MIN=${POMODORO_BREAK_MIN:-5}
STATE="${TMPDIR:-/tmp}/sketchybar_pomodoro"
# One line per work session: "<end epoch> <focused seconds> <completed 0|1>".
# The only record of history; every count and total is derived from it.
LOG="$HOME/.local/share/sketchybar/pomodoro.log"
# Focus length picked on the menu slider; also used when left-click starts a session.
WORK_MIN_FILE="$HOME/.local/share/sketchybar/pomodoro.work_min"
# The slider only stops at these lengths (ascending); the track runs from the first to the last.
CHOICES=(15 25 45 60)
MIN_WORK=${CHOICES[0]} MAX_WORK=${CHOICES[${#CHOICES[@]} - 1]}

nearest_choice() { # $1 = minutes; prints the closest of CHOICES
  local best=${CHOICES[0]} c
  for c in "${CHOICES[@]}"; do
    (((${1} - c) ** 2 < (${1} - best) ** 2)) && best=$c
  done
  echo "$best"
}

# Only the mouse paths need WORK_MIN, so the every-second tick skips this read.
load_work_min() {
  read -r WORK_MIN 2>/dev/null <"$WORK_MIN_FILE"
  # Snap too, so a length saved before the choices changed still lands on one.
  WORK_MIN=$(nearest_choice "${WORK_MIN:-${POMODORO_WORK_MIN:-25}}")
}

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

# Point the slider knob at WORK_MIN and show it on the Start row.
show_duration() {
  sketchybar --set pomodoro.slider slider.percentage=$(((WORK_MIN - MIN_WORK) * 100 / (MAX_WORK - MIN_WORK))) \
    --set pomodoro.start label="Start ${WORK_MIN} min"
}

# Refresh the stats and slider, then show or hide the menu.
toggle_menu() {
  load_work_min
  show_duration
  sketchybar --set pomodoro.stat.today label="$(stat_row Today "$day_start")" \
    --set pomodoro.stat.week label="$(stat_row 'This week' "$week_start")" \
    --set $ITEM popup.drawing=toggle
}

case "$SENDER:$NAME" in
mouse.exited.global:*) close_menu && exit 0 ;;
mouse.clicked:pomodoro.slider)
  # Map 0-100% onto MIN_WORK..MAX_WORK, then snap to the nearest choice; show_duration
  # moves the knob onto it.
  WORK_MIN=$(nearest_choice $((MIN_WORK + ${PERCENTAGE:-0} * (MAX_WORK - MIN_WORK) / 100)))
  mkdir -p "${WORK_MIN_FILE%/*}" && echo "$WORK_MIN" >"$WORK_MIN_FILE"
  show_duration
  exit 0
  ;;
mouse.clicked:pomodoro.start)
  close_menu
  log_abandoned
  load_work_min
  start work $((WORK_MIN * 60))
  ;;
mouse.clicked:pomodoro.reset)
  close_menu
  log_abandoned
  phase=idle running=0 value=0 length=0
  ;;
mouse.clicked:$ITEM)
  if [ "$BUTTON" = "right" ]; then
    toggle_menu
    exit 0
  elif [ "$phase" = idle ]; then
    load_work_min
    start work $((WORK_MIN * 60))
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
