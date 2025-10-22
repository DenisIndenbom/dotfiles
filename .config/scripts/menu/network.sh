#!/usr/bin/env bash

# Rofi configuration (customize this)
rofi_cmd="rofi -dmenu -i -p '󰖩' -theme ~/.config/rofi/network.rasi"

# Optional: Notification timeout in milliseconds
notify_timeout=3000

notify-send -t "$notify_timeout" "Scanning for available Wi-Fi networks..."

# Get list of available networks: show security icon and SSID
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list \
    | sed 1d \
    | sed 's/  */ /g' \
    | sed -E "s/WPA*.?\S/ /g" \
    | sed "s/^--/ /g" \
    | sed "s/  //g" \
    | sed "/--/d")

# Get current Wi-Fi status (enabled/disabled)
wifi_status=$(nmcli -fields WIFI g)
if [[ "$wifi_status" =~ "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
else
    toggle="󰖩  Enable Wi-Fi"
fi

# Use rofi to display menu
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | eval "$rofi_cmd")
read -r chosen_id <<< "${chosen_network:3}"


if [[ -z "$chosen_network" ]]; then
    exit 0

elif [[ "$chosen_network" = "󰖩  Enable Wi-Fi" ]]; then
    nmcli radio wifi on && notify-send -t "$notify_timeout" "Wi-Fi Enabled"

elif [[ "$chosen_network" = "󰖪  Disable Wi-Fi" ]]; then
    nmcli radio wifi off && notify-send -t "$notify_timeout" "Wi-Fi Disabled"

else
    success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
    saved_connections=$(nmcli -g NAME connection)

    if grep -qw "$chosen_id" <<< "$saved_connections"; then
        # Connect to saved network
        if nmcli connection up id "$chosen_id" | grep -q "successfully"; then
            notify-send -t "$notify_timeout" "Connection Established" "$success_message"
        else
            notify-send -u critical "Failed to connect to \"$chosen_id\""
        fi
    else
        # Ask for password if the network is secure
        if [[ "$chosen_network" =~ "" ]]; then
            wifi_password=$(rofi -dmenu -password -p "Enter password for $chosen_id:" )
        fi

        if nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep -q "successfully"; then
            notify-send -t "$notify_timeout" "Connection Established" "$success_message"
        else
            notify-send -u critical "Failed to connect to \"$chosen_id\""
        fi
    fi
fi
