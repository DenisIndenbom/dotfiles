#!/usr/bin/env bash

config="$HOME/.config/rofi/screen.rasi"
script="$HOME/.config/scripts/utilities/screenshot.sh"

declare -A options=(
    [""]="--shot"
    ["󰗆"]="--area"
    [""]="--window"
    ["󰄉"]="--timer"
)

menu="$(printf '%s\n' "${!options[@]}")"
chosen="$(printf '%s\n' "$menu" | rofi \
    -theme "$config" \
    -dmenu \
    -selected-row 0 \
    -theme-str 'listview {lines: 4;}')"

[[ -z "$chosen" ]] && exit 0

if [[ -n "${options[$chosen]}" ]]; then
    "$script" "${options[$chosen]}"
fi