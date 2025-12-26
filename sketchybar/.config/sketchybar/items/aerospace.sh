#!/bin/bash

INDEX=0
ALL_WORKSPACES=$(aerospace list-workspaces --all)

space=(
  background.color=0x44ffffff
  # background.color=$BACKGROUND_1
  background.corner_radius=10
  background.padding_left=0
  background.padding_right=0
  background.drawing=off
  label.padding_left=8
  label.padding_right=8
  label.font="sketchybar-app-font:Regular:16.0"
  icon.drawing=off
  icon.font="SF Pro:Bold:16.0"
  icon.padding_left=8
  icon.padding_right=7
)

space_separator=(
  icon=""
  icon.color=0xffc9c7cd
  icon.padding_left=1
  icon.font="CaskaydiaCove Nerd Font Mono:Regular:20.0"
  label.drawing=off
)

for sid in $ALL_WORKSPACES; do
  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change front_app_switched \
    --set space.$sid "${space[@]}" \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"

  if [[ $sid != $(echo "$ALL_WORKSPACES" | tail -n1) ]]; then
    sketchybar --add item space_separator.$sid left \
      --set space_separator.$sid "${space_separator[@]}"
  fi

  INDEX=$((INDEX + 1))
done
