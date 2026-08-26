#!/bin/sh

# Kill already running processs
process="xsettingsd xsetroot xautolock polybar picom dunst xfce4-power-manager polkit-gnome"
for processed in $process; do
  if [ "$(pidof "$processed")" ]; then
	  killall -9 "$processed"
  fi
done

# Fix Java programs
export _JAVA_AWT_WM_NONREPARENTING=1

# Load xsettingsd
xsettingsd &

# Fix cursor
xsetroot -cursor_name left_ptr &

# Autolock
xautolock -detectsleep -time 5 -locker "$HOME/.config/scripts/utilities/lockscreen.sh" &

# Power Management
xfce4-power-manager &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Set/Restore wallpaper
feh --bg-fill -r "$HOME/.wall" &

# Panel
sh "$HOME/.config/scripts/system/panel.sh" &

# Notification
sh "$HOME/.config/scripts/system/notifications.sh" &

# Compositor
sh "$HOME/.config/scripts/system/compositor.sh" &
