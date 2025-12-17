#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ACTIVE_COLOR="$BLUE"
INACTIVE_COLOR="$WHITE"
INACTIVE_COLOR="0x44FFFFFF"

if [ $SENDER = "aerospace_workspace_change" ]; then
  if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    # sketchybar --set $NAME background.color=0x88FF00FF background.border_width=2
    sketchybar --set $NAME background.color=$ACTIVE_COLOR background.border_width=2
  else
    sketchybar --set $NAME background.color="$INACTIVE_COLOR" background.border_width=0
    # sketchybar --set $NAME background.color=$WHITE background.border_width=0
  fi
else
  CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)
  if [ "$1" = "$CURRENT_WORKSPACE" ]; then
    # sketchybar --set $NAME background.color=0x88FF00FF background.border_width=2 # #FF00FF
    sketchybar --set "$NAME" background.color="$ACTIVE_COLOR" background.border_width=2 # #FF00FF
  else
    sketchybar --set "$NAME" background.color="$INACTIVE_COLOR" background.border_width=0 #FFFFFF
  fi
fi
