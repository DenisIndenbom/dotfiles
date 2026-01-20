#!/bin/bash

STATE=$(polybar-msg hook tray 1 2>/dev/null | grep -o 'visible:...' | cut -d: -f2)

if [ "$STATE" = "false" ]; then
    polybar-msg action "#tray.module_show"
    echo "󰈈"
else
    polybar-msg action "#tray.module_hide"
    echo "󰈉"
fi