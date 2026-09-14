#!/bin/sh

BAR_HEIGHT="${BAR_HEIGHT:-20}"
YAD_WIDTH="${YAD_WIDTH:-222}"
YAD_HEIGHT="${YAD_HEIGHT:-193}"
RIGHT_OFFSET="${RIGHT_OFFSET:-55}"

if [ "$(xdotool getwindowfocus getwindowname 2>/dev/null)" = "yad-calendar" ]; then
    exit 0
fi

WIDTH=$(xdotool getdisplaygeometry | cut -d' ' -f1)

pos_x=$(( (WIDTH - YAD_WIDTH - RIGHT_OFFSET) / 2 ))
pos_y=$BAR_HEIGHT

exec yad --calendar \
    --undecorated \
    --fixed \
    --close-on-unfocus \
    --no-buttons \
    --width="$YAD_WIDTH" \
    --height="$YAD_HEIGHT" \
    --posx="$pos_x" \
    --posy="$pos_y" \
    --title="yad-calendar" \
    --borders=0 \
    >/dev/null