#!/bin/sh

theme="$HOME/.config/rofi/menu.rasi"
theme_str='textbox-prompt-colon{str: "System";}'

shutdown=""
reboot=""
lock="󰌾"
suspend="󰖔"
logout="󰗽"

chosen="$(printf "%s\n%s\n%s\n%s\n%s\n" "$shutdown" "$reboot" "$lock" "$suspend" "$logout" | rofi -theme "$theme" -theme-str "$theme_str" -p "$(uptime -p)" -dmenu -selected-row 2)"

execute () {
  yad --title "Are you sure you want to $2?" --button "Yes":0 --button "No":1 --buttons-layout center --center --on-top --fixed
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
    execute "reboot" "reboot"
  ;;
  "$lock")
    sh "$HOME/.config/scripts/utilities/lockscreen.sh"
  ;;
  "$suspend")
    execute "systemctl suspend-then-hibernate" "suspend"
  ;;
  "$logout")
    execute "i3-msg exit" "quit"
  ;;
esac
