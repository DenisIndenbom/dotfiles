#!/usr/bin/env bash

# Check if playerctl is installed
if ! command -v playerctl &>/dev/null; then
    notify-send -u critical "playerctl not found" "Please install playerctl."
    exit 1
fi

rofi_command="rofi -theme $HOME/.config/rofi/menu.rasi -dmenu -selected-row 1"

MAX_LEN=15

get_song() {
    local fallback="${1:-no music}"
    local song

    # Try artist - title
    song=$(playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null)
    # If that gives empty or just " - ", fall back to title only
    if [[ -z "$song" || "$song" == " - " ]]; then
        song=$(playerctl metadata --format "{{ title }}" 2>/dev/null)
    fi
    # If still empty, use the provided fallback
    [[ -z "$song" ]] && song="$fallback"

    # Replace newlines with spaces, collapse multiple spaces, trim
    song=$(printf "%s" "$song" | tr -d '\n')

    # Truncate if needed
    if [[ ${#song} -gt $MAX_LEN ]]; then
        song="${song:0:$MAX_LEN}..."
    fi

    printf "%s" "$song"
}

# Get player status and current song
status=$(playerctl status 2>/dev/null)

if [[ -z "$status" ]]; then
    # No player running
    status="Stopped"
    current="no player"
else
    # Player is running – fetch and sanitise the song info
    current=$(get_song "no music")
fi

# Play / Pause icon
if [[ "$status" == "Playing" ]]; then
    play_pause=""
else
    play_pause=""
fi

stop=""
next="󰼧"
previous="󰼨"

options="$previous\n$play_pause\n$next\n$stop"

# Spawn rofi menu with current song as prompt
chosen="$(echo -e "$options" | $rofi_command -p "$current" -theme-str 'textbox-prompt-colon{str: "Player";} listview{columns:4;}' )"

case $chosen in
    $previous)
        playerctl previous
        new_song=$(get_song "unknown")
        notify-send -u low -t 1800 " $new_song"
        ;;
    $play_pause)
        playerctl play-pause
        ;;
    $stop)
        playerctl stop
        ;;
    $next)
        playerctl next
        new_song=$(get_song "unknown")
        notify-send -u low -t 1800 " $new_song"
        ;;
esac