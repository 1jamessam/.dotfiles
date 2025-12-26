#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

BATT_PERCENT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$BATT_PERCENT" = "" ]; then
  exit 0
fi

COLOR=$WHITE
case ${BATT_PERCENT} in
[5-9][0-9] | 100)
  COLOR=$BLUE
  ;;
[2-4][0-9])
  COLOR=$YELLOW
  ;;
[1][0-9])
  COLOR=$ORANGE
  ;;
*)
  COLOR=$RED
  ;;
esac

if [[ "$CHARGING" != "" ]]; then
  COLOR=$GREEN
fi

battery=(
  label="${BATT_PERCENT}%"
  label.color="$COLOR"
  alias.color="$COLOR"
)
sketchybar --set "$NAME" "${battery[@]}"
