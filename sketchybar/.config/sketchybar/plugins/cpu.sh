#!/bin/bash

CPU=${CPU_USAGE:-0}
CPU=${CPU%%%}

if [ -z "$CPU" ] || [ "$CPU" = "0" ]; then
  exit 0
fi

PERCENT=$(awk -v c="$CPU" 'BEGIN{printf "%.2f", c/100}')

sketchybar --set "$NAME" label="${CPU}%" \
  --push "$NAME" "$PERCENT"
