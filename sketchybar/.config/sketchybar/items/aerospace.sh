#!/bin/bash

# State/cache files live OUTSIDE $CONFIG_DIR — sketchybar's --hotload reloads the
# bar on any change in the config dir. Must match STATE_DIR in plugins/aerospace.sh.
STATE_DIR="${TMPDIR:-/tmp}/sketchybar_aerospace"
mkdir -p "$STATE_DIR"
rm -f "$STATE_DIR/labels"                  # fresh icon cache on (re)load
rmdir "$STATE_DIR/icons.lock" 2>/dev/null  # drop any stale lock

ALL_WORKSPACES=$(aerospace list-workspaces --all)

space=(
  background.color="$BASE"
  background.corner_radius=8
  background.height=26
  background.drawing=off
  label.padding_left=8
  label.padding_right=8
  label.font="sketchybar-app-font:Regular:18.0"
  label.color="$GREY"
  icon.drawing=on
  icon.padding_left=8
  icon.padding_right=4
  icon.font.family="$FONT"
  icon.font.style=Bold
  icon.font.size=16.0
  icon.color="$GREY"
)

sketchybar --add event aerospace_workspace_change

SPACE_ITEMS=()
FIRST=true
for sid in $ALL_WORKSPACES; do
  # The workspace number (icon) is set here at creation — it never changes, and
  # the plugin's diff would skip empty workspaces (their label stays "").
  sketchybar --add item space."$sid" left \
    --set space."$sid" "${space[@]}" icon="$sid" \
    click_script="aerospace workspace $sid"

  # Only the first space item runs the highlight script, subscribed ONLY to
  # aerospace_workspace_change. Keeping the highlight on its own item (separate
  # from the icon rebuild below) means sketchybar won't serialize it behind the
  # slow rebuild, so the highlight updates instantly on a switch.
  if $FIRST; then
    sketchybar --set space."$sid" \
      updates=on \
      script="$CONFIG_DIR/plugins/aerospace.sh" \
      --subscribe space."$sid" aerospace_workspace_change
    FIRST=false
  fi

  SPACE_ITEMS+=(space."$sid")
done

# Group workspaces in an island
sketchybar --add bracket spaces "${SPACE_ITEMS[@]}" \
  --set spaces background.color="$BASE" \
  background.corner_radius=10 \
  background.height=30 \
  background.drawing=on

# Invisible listener that owns the (slow) icon rebuild on its own item so it runs
# concurrently with — and never blocks — the highlight. Driven by front_app_switched
# (apps opening/closing/moving change the icons).
sketchybar --add item aerospace_icons left \
  --set aerospace_icons drawing=off updates=on \
  script="$CONFIG_DIR/plugins/aerospace.sh" \
  --subscribe aerospace_icons front_app_switched

# Seed the initial highlight: the fast path only runs on switch events and the
# icon path never sets colors, so without this the focused workspace wouldn't be
# highlighted until the first switch.
FOCUSED=$(aerospace list-workspaces --focused)
if [ -n "$FOCUSED" ]; then
  printf '%s' "$FOCUSED" > "$STATE_DIR/focused"
  sketchybar --set space."$FOCUSED" \
    background.drawing=on background.border_width=0 \
    background.color="$LAVENDER" icon.color="$BLACK" label.color="$BLACK"
fi
