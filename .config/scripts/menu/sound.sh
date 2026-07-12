#!/usr/bin/env bash

selected=$(
	pactl list sinks | \
	grep -ie "description:" | \
	cut -d: -f2 | \
	sed 's/^[[:space:]]*//' | \
	sort | \
	rofi -dmenu -i -theme ~/.config/rofi/launcher.rasi -p ""
)
[[ -z $selected ]] && exit 0

# Figure out what the device name is based on the description passed.
device=$(pactl list sinks | grep -C2 "Description: ${desc}$" | grep Name | cut -d: -f2 | xargs)

# Try to set the default to the device chosen.
if pactl set-default-sink "$device"
then
	# If it worked, alert the user.
	notify-send -t 2000 -r 2 -u low "Activated: $selected"
else
	# If it didn't work, critically alert the user.
	notify-send -t 2000 -r 2 -u critical "Error activating $selected"
fi