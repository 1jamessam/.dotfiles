#!/bin/bash

# Left click: start / pause / resume.
# Right click: menu to start a session of a given length, or reset.
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
  padding_right=5 # gap from the cpu/memory block (or music) on its right
)

sketchybar --add item pomodoro right \
  --set pomodoro "${pomodoro[@]}" \
  --subscribe pomodoro mouse.clicked mouse.exited.global system_woke

menu_item=(
  icon.drawing=off
  label.padding_left=12
  label.padding_right=12
  script="$PLUGIN_DIR/pomodoro.sh"
)

for min in 15 25 45 60; do
  sketchybar --add item pomodoro.preset.$min popup.pomodoro \
    --set pomodoro.preset.$min "${menu_item[@]}" label="${min} min" \
    --subscribe pomodoro.preset.$min mouse.clicked
done

sketchybar --add item pomodoro.reset popup.pomodoro \
  --set pomodoro.reset "${menu_item[@]}" label="Reset" label.color="$GREY" \
  --subscribe pomodoro.reset mouse.clicked
