#!/bin/sh

config="$HOME/.config/picom/picom.conf"

killall -q picom

picom --config "$config" &
