#!/bin/sh

# --- Colors ---
base="#1e1e2e"
mantle="#181825"
text="#cdd6f4"
green="#a6e3a1"
red="#f38ba8"
accent="#89b4fa"

# --- Fonts ---
font_main="JetBrains Mono"
font_icon="Symbols Nerd Font"

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
    # Indicator
    --indicator \
    --radius 70 \
    --ring-width 6 \
    --ind-pos="w/2:h/2+200" \
    --ring-color="$mantle" \
    --ringver-color="$green" \
    --ringwrong-color="$red" \
    --inside-color="$base" \
    --insidever-color="$mantle" \
    --insidewrong-color="$mantle" \
    --line-uses-inside \
    \
    # Clock
    --time-str="%I:%M %p" \
    --time-font="$font_main" \
    --time-size=70 \
    --time-color="$text" \
    --time-pos="w/2:h/2-160" \
    \
    --date-str="%A, %B %d" \
    --date-font="$font_main" \
    --date-size=28 \
    --date-color="$accent" \
    --date-pos="w/2:h/2-110" \
    \
    # Status messages
    --verif-text="Verifying..." \
    --verif-color="$green" \
    --verif-font="$font_main" \
    --verif-size=18 \
    --verif-pos="w/2:h/2+130" \
    \
    --wrong-text="Incorrect password" \
    --wrong-color="$red" \
    --wrong-font="$font_main" \
    --wrong-size=18 \
    --wrong-pos="w/2:h/2+130" \
    \
    --noinput-text="Waiting for input..." \
    --lock-text="Locking..." \
    --lockfailed-text="Lock failed!" \
    \
    # Greeter (icon)
    --greeter-text="󰌾" \
    --greeter-font="$font_icon" \
    --greeter-size=60 \
    --greeter-color="$accent" \
    --greeter-pos="w/2:h/2+260" \
    \
    # Key highlights
    --keyhl-color="$accent" \
    --bshl-color="$accent" \
    --separator-color="$mantle" \
    --pointer=default \
    \
    # Misc
    --show-failed-attempts
