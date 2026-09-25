#!/bin/sh

icon_path="$HOME/.config/dunst/icons"

clock=$(date +%Y_%m_%d_at_%Hh%Mm%Ss)

dir="$HOME/screenshots"
file="$dir/screenshot_${clock}.png"

[ ! -d "$dir" ] && mkdir -p "$dir"

notify_user() {
	paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga 2>/dev/null &
	notify-send \
		-a Clipboard \
		-i "$icon_path/clipboard.svg" \
		-u low \
		-r 699 "Clipboard" "Screenshot saved on clipboard"
}

countdown() {
	for sec in $(seq "$1" -1 1); do
		notify-send \
			-a Clock \
			-i "$icon_path/timer.svg" \
			-t 1050 \
			-r 699 "Countdown" "Taking shot in : $sec"
		sleep 1
	done
}

capture() {
	cd "$dir" || exit
	if ! maim -u -f png "$@" "$file"; then
		[ -f "$file" ] && rm -f "$file"
		return 1
	fi
	xclip -selection clipboard -t image/png -i "$file" || return 1
	notify_user
}

screen() {
	capture
}

window() {
	capture -i "$(xdotool getactivewindow)"
}

area() {
	capture -s -b 2 -c 0.35,0.55,0.85,0.25 -l
}

timer() {
	countdown 3
	sleep 1
	screen
}

docs() {
	echo "
Usage:	screenshot [Options]
    --help	 -	Prints this message
Options:
    --shot	 -	Take screenshot of the screen
    --window -  Take screenshot of the focused window
    --area	 -	Take screenshot of the selected area
    --timer	 -	Set a custom timer to take a screenshot
	"
}

case $1 in
--shot)
	screen
	;;
--window)
	window
	;;
--area)
	area
	;;
--timer)
	timer
	;;
--help | *)
	docs
	;;
esac