#!/bin/sh

# Get the directory where this script is located
script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

# Source accent color script if it exists
[ -f "$script_dir/accent.sh" ] && sh "$script_dir/accent.sh"

# Remember last used mode (optional)
mode="${1:-$(cat /tmp/rofi_mode 2>/dev/null || echo drun)}"
echo "$mode" > /tmp/rofi_mode

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
