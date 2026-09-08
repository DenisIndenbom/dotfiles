#!/bin/sh

if [ "$(pidof dunst)" ]; then
    killall -9 "dunst"
fi

dunst -config "$HOME/.config/dunst/dunstrc" &
