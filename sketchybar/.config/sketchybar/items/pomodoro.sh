#!/bin/bash

# Left click: start / pause / resume.
# Hover for a second: menu with today's/this week's stats, preset lengths, and reset.
pomodoro=(
  icon=􀐱
  icon.color="$RED"
  icon.padding_left=10
  icon.padding_right=4
  label.font="$FONT:Bold:13.0"
  label.padding_right=10
  update_freq=0
  updates=on
  script="$PLUGIN_DIR/pomodoro.sh"
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
  popup.align=right
  popup.height=26 # menu row height; defaults to the bar height (44), too sparse
  padding_right=5 # gap from the cpu/memory block (or music) on its right
)

sketchybar --add item pomodoro right \
  --set pomodoro "${pomodoro[@]}" \
  --subscribe pomodoro mouse.clicked mouse.entered mouse.exited mouse.exited.global system_woke

# Read-only stat rows at the top of the menu; the plugin fills them in when the menu opens.
# Every menu row reports hover so the menu stays open while the mouse is inside it.
stat_row=(
  icon.drawing=off
  label.padding_left=12
  label.padding_right=12
  label.color="$GREY"
  script="$PLUGIN_DIR/pomodoro.sh"
)

sketchybar --add item pomodoro.stat.today popup.pomodoro \
  --set pomodoro.stat.today "${stat_row[@]}" label.color="$WHITE" \
  --add item pomodoro.stat.week popup.pomodoro \
  --set pomodoro.stat.week "${stat_row[@]}" \
  --add item pomodoro.divider popup.pomodoro \
  --set pomodoro.divider icon.drawing=off label.drawing=off \
  width=150 background.height=1 background.color="$SURFACE_0" \
  background.drawing=on background.y_offset=0 padding_left=12 padding_right=12 \
  --subscribe pomodoro.stat.today mouse.entered mouse.exited \
  --subscribe pomodoro.stat.week mouse.entered mouse.exited

menu_item=(
  icon.drawing=off
  label.padding_left=12
  label.padding_right=12
  script="$PLUGIN_DIR/pomodoro.sh"
)

for min in 15 25 45 60; do
  sketchybar --add item pomodoro.preset.$min popup.pomodoro \
    --set pomodoro.preset.$min "${menu_item[@]}" label="${min} min" \
    --subscribe pomodoro.preset.$min mouse.clicked mouse.entered mouse.exited
done

sketchybar --add item pomodoro.reset popup.pomodoro \
  --set pomodoro.reset "${menu_item[@]}" label="Reset" label.color="$GREY" \
  --subscribe pomodoro.reset mouse.clicked mouse.entered mouse.exited
