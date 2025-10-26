#!/bin/sh

# --- Colors ---
base="#1e1e2e"
mantle="#181825"
text="#cdd6f4"
green="#a6e3a1"
red="#f38ba8"
accent="#89b4fa"

# --- Fonts ---
font="JetBrains Mono"

# --- Background ---
background="$HOME/.lock"
    
# --- Launch i3lock-color ---
i3lock \
    --fill \
    -i "$background" \
    -n -e \
    -c 00000000 \
    --pass-media-keys \
    --pass-power-keys \
    --pass-screen-keys \
    --pass-volume-keys \
    \
    --indicator \
    --ind-pos="w/2:h/2" \
    --radius 100 \
    --ring-width 6 \
    --ring-color="$mantle" \
    --ringver-color="$green" \
    --ringwrong-color="$red" \
    --inside-color="$base" \
    --insidever-color="$mantle" \
    --insidewrong-color="$mantle" \
    --line-uses-inside \
    \
    --clock \
    --time-str="%H:%M" \
    --time-font="$font" \
    --time-size=22 \
    --time-color="$text" \
    \
    --date-str="%Y-%m-%d" \
    --date-font="$font" \
    --date-size=20 \
    --date-color="$accent" \
    \
    --verif-text="Verifying..." \
    --verif-color="$green" \
    --verif-font="$font" \
    --verif-size=16 \
    --verif-pos="w/2:h/2+10" \
    \
    --wrong-text="Incorrect password" \
    --wrong-color="$red" \
    --wrong-font="$font" \
    --wrong-size=16 \
    --wrong-pos="w/2:h/2+10" \
    \
    --keyhl-color="$accent" \
    --bshl-color="$accent" \
    --separator-color="$mantle" \
    --pointer=default \
    \
    --show-failed-attempts \
    --status-pos="w/2:h/2+10"