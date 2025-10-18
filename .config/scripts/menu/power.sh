#!/bin/sh

config="$HOME/.config/rofi/power.rasi"
script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

shutdown=""
reboot=""
lock="󰌾"
suspend="󰖔"
logout="󰗽"

# Source accent color script if it exists
[ -f "$script_dir/accent.sh" ] && sh "$script_dir/accent.sh"

chosen="$(printf "%s\n%s\n%s\n%s\n%s\n" "$shutdown" "$reboot" "$lock" "$suspend" "$logout" | rofi -theme "$config" -p "$(uptime -p)" -dmenu -selected-row 2)"

execute () {
  yad --title "Are you sure you want to $2?" --button "Yes":0 --button "No":1 --buttons-layout center --center --on-top --fixed --no_escape
  exit=$?

  if [ "$exit" -eq 0 ]; then
    $1
  fi
}

case "$chosen" in
  "$shutdown")
    execute "shutdown -h now" "shutdown"
  ;;
  "$reboot")
    execute "reboot -h now" "reboot"
  ;;
  "$lock")
    sh "$HOME/.config/scripts/utilities/lockscreen.sh"
  ;;
  "$suspend")
    execute "systemctl suspend" "suspend"
  ;;
  "$logout")
    execute "kill -9 -1" "quit"
  ;;
esac
