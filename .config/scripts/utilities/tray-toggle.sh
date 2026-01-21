#!/bin/bash

# Get current tray visibility state
STATE=$(polybar-msg hook tray 1 2>/dev/null | grep -o 'visible:...' | cut -d: -f2)

if [ -z "$STATE" ]; then
    echo "󰈉"
    exit 0
fi

# Show icon based on CURRENT state, then toggle
if [ "$STATE" = "false" ]; then
    echo "󰈉"  # Currently hidden, shows eye icon
    polybar-msg action "#tray.module_show" 2>/dev/null
else
    echo "󰈈"  # Currently visible, shows eye with slash
    polybar-msg action "#tray.module_hide" 2>/dev/null
fi