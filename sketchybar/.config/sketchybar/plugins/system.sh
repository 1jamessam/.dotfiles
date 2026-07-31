#!/bin/bash

source "$CONFIG_DIR/colors.sh"

case "$NAME" in
cpu)
  USAGE=${CPU_USAGE:-}
  ;;
memory)
  USAGE=${RAM_USAGE:-}
  # macOS keeps RAM ~80% used by design (compressor + cache), so the percentage
  # is a bad alarm on its own. Colour this row by the kernel's pressure level:
  # 1 normal, 2 warning, 4 critical. Falls back to the usage thresholds below if
  # the sysctl ever stops reporting one of those.
  PRESSURE=$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)
  ;;
esac

USAGE=${USAGE%%%} # drop the unit the stats provider appends
USAGE=${USAGE%.*} # drop any fractional part

case "$USAGE" in
'' | *[!0-9]*)
  exit 0
  ;;
esac

case "${PRESSURE:-}" in
1)
  COLOR=$WHITE
  ;;
2)
  COLOR=$YELLOW
  ;;
4)
  COLOR=$RED
  ;;
*)
  COLOR=$WHITE
  if [ "$USAGE" -ge 90 ]; then
    COLOR=$RED
  elif [ "$USAGE" -ge 70 ]; then
    COLOR=$YELLOW
  fi
  ;;
esac

sketchybar --set "$NAME" label="${USAGE}%" label.color="$COLOR"
