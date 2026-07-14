#!/bin/sh

# Kill already running processs
process="xsettingsd polybar picom dunst mpd mpDris2 xfce4-power-manager"
for processed in $process; do
  if [ "$(pidof "$processed")" ]; then
	  killall -9 "$processed"
  fi
done

# Load xsettingsd &
xsettingsd &

# Fix cursor
xsetroot -cursor_name left_ptr &

# Fix Java programs
export _JAVA_AWT_WM_NONREPARENTING=1

# Power Management
xfce4-power-manager &

# Set/Restore wallpaper
feh --bg-fill -r "$HOME/.wall" &

# Panel
sh "$HOME/.config/scripts/system/panel.sh" &

# Notification
sh "$HOME/.config/scripts/system/notifications.sh" &

# Compositor
sh "$HOME/.config/scripts/system/compositor.sh" &
