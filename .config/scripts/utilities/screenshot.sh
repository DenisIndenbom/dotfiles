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
	if ! grim "$@" "$file"; then
		[ -f "$file" ] && rm -f "$file"
		return 1
	fi
	wl-copy --type image/png < "$file" || return 1
	notify_user
}

screen() {
	capture
}

window() {
	capture -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"')"
}

area() {
	capture -g "$(slurp -b 2 -c '#598cd940')"
}

timer() {
	countdown 3
	sleep 1
	screen
}

menu() {
	config="$HOME/.config/rofi/screen.rasi"

	screen=""
	area="󰗆"
	window=""
	timer="󰄉"

	chosen="$(printf "%s\n%s\n%s\n%s\n" "$screen" "$area" "$window" "$timer" | rofi -theme "$config" -p 'Take Screenshot' -dmenu -selected-row 0 -theme-str 'listview {lines: 4;}')"

	case $chosen in
	"$screen")
		screen
		;;
	"$area")
		area
		;;
	"$window")
		window
		;;
	"$timer")
		timer
		;;
	esac
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
    --menu	 -	Opens a gui selector
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
--menu)
	menu
	;;
--help | *)
	docs
	;;
esac