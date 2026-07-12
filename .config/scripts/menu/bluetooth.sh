#!/usr/bin/env bash

if [ "$1" = "--status" ]; then
    dmenu-bluetooth --status
else
    export DMENU_BLUETOOTH_LAUNCHER="rofi -dmenu"
    dmenu-bluetooth "$@" --connected-icon 󰂱
fi