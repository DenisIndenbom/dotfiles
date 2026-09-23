#!/bin/sh

# Kill already running processes
process="batsignal powerkit polkit-gnome-authentication-agent-1"
for processed in $process; do
  if [ "$(pidof "$processed")" ]; then
	  killall -9 "$processed"
  fi
done

# Power Management
powerkit &
batsignal -b -N \
  -w 10 -c 5 \
  -W "Battery low" \
  -C "Battery critical" \
  -M "notify-send -u critical -i $HOME/.config/dunst/icons/battery-low.svg '%s' 'Level: %s%%'"

# Polkit Auth Agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Set/Restore wallpaper
swaybg -m fill -i "$HOME/.wall" &

# Autolock
swayidle -w \
  timeout 110 'brightnessctl -s set 10%' resume 'brightnessctl -r' \
  timeout 120 '~/.config/scripts/utilities/lockscreen.sh' resume 'brightnessctl -r' \
  before-sleep '~/.config/scripts/utilities/lockscreen.sh' &

# Notification
dunst -config "$HOME/.config/dunst/dunstrc" &

# Panel
waybar &