#!/bin/sh

# Kill already running processes
process="xautolock xss-lock polybar picom dunst powerkit polkit-gnome-authentication-agent-1"
for processed in $process; do
  if [ "$(pidof "$processed")" ]; then
	  killall -9 "$processed"
  fi
done

# Fix Java programs
export _JAVA_AWT_WM_NONREPARENTING=1

# Autolock
xautolock -detectsleep -time 2 -locker "$HOME/.config/scripts/utilities/lockscreen.sh" &
xss-lock .config/scripts/utilities/lockscreen.sh &

# Power Management
powerkit &

# Polkit Auth Agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Set/Restore wallpaper
feh --bg-fill -r "$HOME/.wall" &

# Panel
sh "$HOME/.config/scripts/system/panel.sh" &

# Notification
sh "$HOME/.config/scripts/system/notifications.sh" &

# Compositor
sh "$HOME/.config/scripts/system/compositor.sh" &