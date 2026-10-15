#!/bin/bash

# Left click: start / pause / resume.
# Right click: menu with today's/this week's stats, a focus-length slider, Start, and Reset.
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
  --subscribe pomodoro mouse.clicked mouse.exited.global system_woke

# Read-only stat rows at the top of the menu; the plugin fills them in when the menu opens.
stat_row=(
  icon.drawing=off
  label.padding_left=12
  label.padding_right=12
  label.color="$GREY"
)

sketchybar --add item pomodoro.stat.today popup.pomodoro \
  --set pomodoro.stat.today "${stat_row[@]}" label.color="$WHITE" \
  --add item pomodoro.stat.week popup.pomodoro \
  --set pomodoro.stat.week "${stat_row[@]}" \
  --add item pomodoro.divider popup.pomodoro \
  --set pomodoro.divider icon.drawing=off label.drawing=off \
  width=150 background.height=1 background.color="$SURFACE_0" \
  background.drawing=on background.y_offset=0 padding_left=12 padding_right=12

menu_item=(
  icon.drawing=off
  label.padding_left=12
  label.padding_right=12
  script="$PLUGIN_DIR/pomodoro.sh"
)

# Drag or click the slider to pick a focus length; the plugin snaps it to 5-minute steps,
# shows it on the Start row, and remembers it for left-click starts too.
duration_slider=(
  script="$PLUGIN_DIR/pomodoro.sh"
  icon.drawing=off
  label.drawing=off
  padding_left=12
  padding_right=12
  slider.highlight_color="$RED"
  slider.background.height=4
  slider.background.corner_radius=2
  slider.background.color="$SURFACE_0"
  slider.knob=􀀁
  slider.knob.color="$WHITE"
  slider.knob.font="$FONT:Bold:12.0"
  # Sliders have no tick marks, so labelled ticks (15/25/45/60 min) are drawn as the item
  # background behind the track; its height also makes room for the numbers. Regenerate it
  # with images/make_slider_ticks.swift if the slider width or the plugin's CHOICES change.
  background.drawing=on
  background.color="$TRANSPARENT"
  background.height=44
  background.image="$CONFIG_DIR/images/pomodoro_ticks.png"
  background.image.scale=0.5
  background.image.drawing=on
)

sketchybar --add slider pomodoro.slider popup.pomodoro 150 \
  --set pomodoro.slider "${duration_slider[@]}" \
  --subscribe pomodoro.slider mouse.clicked \
  --add item pomodoro.start popup.pomodoro \
  --set pomodoro.start "${menu_item[@]}" \
  --subscribe pomodoro.start mouse.clicked

sketchybar --add item pomodoro.reset popup.pomodoro \
  --set pomodoro.reset "${menu_item[@]}" label="Reset" label.color="$GREY" \
  --subscribe pomodoro.reset mouse.clicked
