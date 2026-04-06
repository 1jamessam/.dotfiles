#!/bin/bash

if [ "$SENDER" = "front_app_switched" ]; then
	sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" \
		--animate tanh 8 --set "$NAME" icon.y_offset=10 \
		--animate tanh 8 --set "$NAME" icon.y_offset=0
fi

