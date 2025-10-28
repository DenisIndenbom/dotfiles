#!/bin/sh

script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
icon_path="$HOME/.config/dunst/icons"
colorscheme=mocha

clock=$(date +%Y-%m-%d-%I-%M-%S)
geometry=$(xrandr | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current')

dir="$(xdg-user-dir PICTURES)/screenshots"
file="screenshot_${clock}_${geometry}.png"

[ ! -d "$dir" ] && mkdir -p "$dir"

notify_user() {
	paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga 2>/dev/null &
	notify-send \
		-a Clipboard \
		-i "$icon_path/$colorscheme/clipboard.svg" \
		-u low \
		-r 699 "Clipboard" "Screenshot saved on clipboard"
}

countdown() {
	for sec in $(seq "$1" -1 1); do
		notify-send \
			-a Clock \
			-u normal \
			-t 1000 \
			-i "$icon_path/$colorscheme/timer.svg" \
			"Countdown" "Taking shot in : $sec"
		sleep 1
	done
}

screen() {
	cd "$dir" || exit
	maim -u -f png "$file"
	xclip -selection clipboard -t image/png -i "$file"
	notify_user
}

window() {
	cd "$dir" || exit
	maim -u -f png -i "$(xdotool getactivewindow)" "$file"
	xclip -selection clipboard -t image/png -i "$file"
	notify_user
}

area() {
	cd "$dir" || exit
	maim -u -f png -s -b 2 -c 0.35,0.55,0.85,0.25 -l "$file"
	xclip -selection clipboard -t image/png -i "$file"
	notify_user
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
