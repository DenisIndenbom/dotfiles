#!/bin/bash

WALL_DIR="$HOME/.config/wallpapers"

SELECTED=$(
	find "$WALL_DIR" -type f | while read -r img; do
 	[[ "$img" =~ \.(jpg|jpeg|png|webp|JPG|PNG)$ ]] || continue

        REL_PATH="${img#$WALL_DIR/}"
	printf "%s\0icon\x1f%s\n" "$REL_PATH" "$img"
    done | rofi \
        -dmenu \
        -i \
        -show-icons \
        -theme ~/.config/rofi/wallpaper.rasi \
        -p ""
)

[[ -z "$SELECTED" ]] && exit 0

cp "$WALL_DIR/$SELECTED" "$HOME/.wall"
feh --bg-fill -r "$HOME/.wall" &