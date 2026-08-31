#!/bin/sh

# Launch Rofi with custom theme
rofi \
  -show drun \
  -show-icons \
  -no-lazy-grab \
  -scroll-method 0 \
  -drun-match-fields all \
  -drun-display-format "{name}" \
  -kb-cancel Escape \
  -theme "$HOME/.config/rofi/launcher.rasi"
