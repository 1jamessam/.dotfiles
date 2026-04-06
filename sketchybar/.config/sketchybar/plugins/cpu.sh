#!/bin/bash

CPU=$(top -l 1 -n 0 | awk '/CPU usage/ {
  user = $3; sys = $5
  gsub(/%/, "", user); gsub(/%/, "", sys)
  printf "%.0f", user + sys
}')
PERCENT=$(echo "$CPU / 100" | bc -l)

sketchybar --set "$NAME" label="${CPU}%" \
  --push "$NAME" "$PERCENT"
