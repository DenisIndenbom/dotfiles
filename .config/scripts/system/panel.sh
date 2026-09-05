#!/bin/sh

cache="$HOME/.cache/polybar"
config="$HOME/.config/polybar"

mkdir -p "$cache" 2>/dev/null

get_values () {
  card=$(brightnessctl -l | awk '/backlight/ {gsub(/'\''/, "", $2); print $2; exit}')
  battery=$(upower -i "$(upower -e | grep 'BAT')" | grep 'native-path' | cut -d':' -f2 | tr -d '[:blank:]')
  adapter=$(upower -i "$(upower -e | grep 'AC')" | grep 'native-path' | cut -d':' -f2 | tr -d '[:blank:]')
  interface=$(ip link | awk '/state UP/ {print $2}' | tr -d :)
}

set_values () {
  if [ "$adapter" ]; then
    sed -i -e "s/adapter = .*/adapter = $adapter/g" "$config/system.ini"
  fi

  if [ "$battery" ]; then
    sed -i -e "s/battery = .*/battery = $battery/g" "$config/system.ini"
  fi

  if [ "$card" ]; then
    sed -i -e "s/graphics_card = .*/graphics_card = $card/g" "$config/system.ini"
  fi

  if [ "$interface" ]; then
    sed -i -e "s/network_interface = .*/network_interface = $interface/g" "$config/system.ini"
  fi
}


launch_bar () {
  # Kill already running bars
  if [ "$(pidof "polybar")" ]; then
	  killall -9 "polybar"
  fi

  # Launch bar on each monitor
  monitors=$(polybar -m)
  echo "$monitors" | while IFS=: read -r monitor rest; do
    # Skip empty lines
    [ -z "$monitor" ] && continue

    # Check if this monitor is primary
    if [[ "$rest" == *"primary"* ]]; then
        MONITOR="$monitor" polybar main &> /dev/null &
    else
        MONITOR="$monitor" polybar external &> /dev/null &
    fi
  done
}

if [ ! -f "$cache/system.ini" ]; then
  get_values
  set_values
  touch "$cache/system.ini"
fi

launch_bar
