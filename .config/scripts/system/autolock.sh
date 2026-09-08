#!/bin/sh

if [ "$(pidof xidlehook)" ]; then
    killall -9 "xidlehook"
fi

if [ "$(pidof xss-lock)" ]; then
    killall -9 "xss-lock"
fi

xidlehook \
  --detect-sleep \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 110 \
    'brightnessctl -s set 10%' \
    'brightnessctl -r' \
  --timer 10 \
    '$HOME/.config/scripts/utilities/lockscreen.sh' \
    'brightnessctl -r' &

xss-lock ".config/scripts/utilities/lockscreen.sh" &
