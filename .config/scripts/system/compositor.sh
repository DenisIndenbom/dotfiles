#!/bin/sh

if [ "$(pidof picom)" ]; then
    killall -9 "picom"
fi

picom --config "$HOME/.config/picom/picom.conf" &
