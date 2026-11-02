#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

BATT_PERCENT=${BATTERY_PERCENTAGE:-}
BATT_PERCENT=${BATT_PERCENT%%%}
BATT_STATE=${BATTERY_STATE:-}

if [ -z "$BATT_PERCENT" ]; then
  exit 0
fi

case ${BATT_PERCENT} in
9[0-9] | 100) ICON=$BATTERY_100 ;;
[6-8][0-9]) ICON=$BATTERY_75 ;;
[3-5][0-9]) ICON=$BATTERY_50 ;;
[1-2][0-9]) ICON=$BATTERY_25 ;;
*) ICON=$BATTERY_0 ;;
esac

COLOR=$WHITE
case ${BATT_PERCENT} in
[5-9][0-9] | 100)
  COLOR=$GREEN
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

if [[ "$BATT_STATE" == "charging" || "$BATT_STATE" == "charged" || "$BATT_STATE" == "full" ]]; then
  COLOR=$GREEN
  ICON=$BATTERY_CHARGING
fi

battery=(
  icon="$ICON"
  icon.color="$COLOR"
  label="${BATT_PERCENT}%"
  label.color="$COLOR"
)
sketchybar --set "$NAME" "${battery[@]}"
