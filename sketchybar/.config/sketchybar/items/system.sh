#!/bin/bash

COLOR="$TEAL"

# cpu sits above memory in one column. Right-side items draw leftward from their
# own right edge, so memory (added first) is width=0: that leaves cpu's origin on
# the same edge and the two rows overlap instead of sitting side by side. cpu
# carries the width the bracket sizes itself to. Both rows need identical
# fonts/paddings to stay aligned.
row=(
  icon.color="$COLOR"
  icon.font="$FONT:Bold:11.0"
  icon.padding_left=4
  icon.padding_right=4
  label="--%"
  label.font="$FONT:Semibold:11.0"
  label.width=34 # fits "100%" (31px) plus the paddings below
  label.align=left
  label.padding_left=0
  label.padding_right=2
  script="$PLUGIN_DIR/system.sh"
)

memory=(
  "${row[@]}"
  icon=􀫦
  y_offset=-6
  width=0
)

cpu=(
  "${row[@]}"
  icon=􀫥
  y_offset=6
)

system_bracket=(
  background.color="$BASE"
  background.corner_radius=10
  background.height=30
  background.drawing=on
)

# A bracket's background is drawn over its members' region, so padding on the
# bracket or on cpu/memory only grows the block — it never separates it from the
# statuses block. An unbracketed spacer added first (i.e. to the right of the
# rows) is what actually opens the gap.
system_gap=(
  width=3
  padding_left=0
  padding_right=0
  label.drawing=off
  icon.drawing=off
  background.drawing=off
)

# memory is added first so both rows share the same right edge
sketchybar \
  --add item system_gap right \
  --set system_gap "${system_gap[@]}" \
  --add item memory right \
  --set memory "${memory[@]}" \
  --subscribe memory system_stats \
  --add item cpu right \
  --set cpu "${cpu[@]}" \
  --subscribe cpu system_stats \
  --add bracket system cpu memory \
  --set system "${system_bracket[@]}"
