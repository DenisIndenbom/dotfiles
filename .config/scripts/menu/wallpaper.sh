#!/bin/bash

WALL_DIRS=(
    "$HOME/.config/wallpapers"
    "$HOME/wallpapers"
)

SELECTED=$(
    for WALL_DIR in "${WALL_DIRS[@]}"; do
        [[ -d "$WALL_DIR" ]] || continue

        find "$WALL_DIR" -type f | while read -r img; do
            [[ "$img" =~ \.(jpg|jpeg|png|webp|JPG|JPEG|PNG|WEBP)$ ]] || continue

            NAME=$(basename "$img")
            printf "%s\0icon\x1f%s\n" "$NAME" "$img"
        done
    done | rofi \
        -dmenu \
        -i \
        -show-icons \
        -theme ~/.config/rofi/wallpaper.rasi \
        -p ""
)

[[ -z "$SELECTED" ]] && exit 0

for WALL_DIR in "${WALL_DIRS[@]}"; do
    if [[ -f "$WALL_DIR/$SELECTED" ]]; then
        ln -sf "$WALL_DIR/$SELECTED" "$HOME/.wall"
        break
    fi
done

feh --bg-fill "$HOME/.wall" &