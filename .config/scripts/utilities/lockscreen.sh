#!/bin/sh

# --- Colors ---
base="#1e1e2e"
mantle="#181825"
text="#cdd6f4"
green="#a6e3a1"
red="#f38ba8"
accent="#b4befe"

# --- Fonts ---
font="JetBrains Mono"

# --- Background ---
background="$HOME/.lock"

# --- Check swaylock is not running ---
if [ "$(pidof swaylock)" ]; then
    exit
fi

# --- Launch swaylock-effects ---
swaylock \
    --image "$background" \
    --scaling fill \
    --color 00000000 \
    --ignore-empty-password \
    \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 6 \
    --ring-color "$mantle" \
    --ring-ver-color "$green" \
    --ring-wrong-color "$red" \
    --ring-clear-color "$accent" \
    --inside-color "$base" \
    --inside-ver-color "$mantle" \
    --inside-wrong-color "$mantle" \
    --inside-clear-color "$mantle" \
    --line-uses-inside \
    --line-clear-color "$accent" \
    \
    --clock \
    --timestr "%H:%M" \
    --datestr "%Y-%m-%d" \
    --font "$font" \
    --font-size 20 \
    --text-color "$text" \
    --text-ver-color "$green" \
    --text-wrong-color "$red" \
    --text-clear-color "$accent" \
    \
    --key-hl-color "$accent" \
    --bs-hl-color "$accent" \
    --separator-color "$mantle" \
    --show-failed-attempts \
    \
    --hide-keyboard-layout \
    --layout-bg-color "$mantle" \
    --layout-border-color "$accent" \
    --layout-text-color "$text"