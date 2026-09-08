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
feh --bg-fill -r "$HOME/.wall" &

# Autolock
sh "$HOME/.config/scripts/system/autolock.sh" &

# Panel
sh "$HOME/.config/scripts/system/panel.sh" &

# Notification
sh "$HOME/.config/scripts/system/notifications.sh" &

# Compositor
sh "$HOME/.config/scripts/system/compositor.sh" &