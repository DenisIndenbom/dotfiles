#!/usr/bin/env bash

# Constants
divider="---------"
goback="Back"

# Rofi command to pipe into, can add any options here
rofi_command="rofi -dmenu $* -theme ~/.config/rofi/dmenu.rasi -i -p 󰂯"

# --------------------------
# Notification helper
# --------------------------
notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@"
    fi
}

# --------------------------
# Dependency checks
# --------------------------
check_dependencies() {
    local missing=()
    for cmd in bluetoothctl rofi; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing required commands: ${missing[*]}" >&2
        notify -u critical "Bluetooth" "Missing required commands: ${missing[*]}"
        exit 1
    fi
    # rfkill is optional but used in toggle_power
    if ! command -v rfkill >/dev/null 2>&1; then
        echo "Warning: rfkill not found. Power toggling may not work if Bluetooth is rfkill-blocked." >&2
        notify -u normal "Bluetooth" "Warning: rfkill not found. Power toggling may fail if blocked."
    fi
}

# --------------------------
# Controller status functions
# --------------------------

# Returns 0 if controller is powered on
power_on() {
    bluetoothctl show | grep -q "Powered: yes"
}

# Toggles power state
toggle_power() {
    if power_on; then
        if ! bluetoothctl power off; then
            notify -u critical "Bluetooth" "Failed to power off"
            return 1
        fi
    else
        # If rfkill blocked, unblock first
        if command -v rfkill >/dev/null 2>&1 && rfkill list bluetooth | grep -q 'blocked: yes'; then
            if ! rfkill unblock bluetooth; then
                notify -u critical "Bluetooth" "Failed to unblock Bluetooth"
                return 1
            fi
            # Wait for controller to become available
            for _ in {1..10}; do
                sleep 1
                if bluetoothctl show >/dev/null 2>&1; then
                    break
                fi
            done
        fi
        if ! bluetoothctl power on; then
            notify -u critical "Bluetooth" "Failed to power on"
            return 1
        fi
    fi
    show_menu
}

# Returns 0 if controller is scanning
scan_on() {
    bluetoothctl show | grep -q "Discovering: yes"
}

# Performs a scan for devices (blocking, with timeout)
perform_scan() {
    if scan_on; then
        notify -t 2000 "Bluetooth" "Scan already in progress"
        return
    fi
    notify -t 5000 "Bluetooth" "Scanning for devices..."
    if ! bluetoothctl --timeout 5 scan on; then
        notify -u critical "Bluetooth" "Scan failed"
        return 1
    fi
}

# Returns 0 if controller is pairable
pairable_on() {
    bluetoothctl show | grep -q "Pairable: yes"
}

# Toggles pairable state
toggle_pairable() {
    if pairable_on; then
        bluetoothctl pairable off
    else
        bluetoothctl pairable on
    fi
    show_menu
}

# Returns 0 if controller is discoverable
discoverable_on() {
    bluetoothctl show | grep -q "Discoverable: yes"
}

# Toggles discoverable state
toggle_discoverable() {
    if discoverable_on; then
        bluetoothctl discoverable off
    else
        bluetoothctl discoverable on
    fi
    show_menu
}

# --------------------------
# Device functions
# --------------------------

# Returns 0 if device is connected
device_connected() {
    local mac="$1"
    bluetoothctl info "$mac" | grep -q "Connected: yes"
}

# Returns 0 if any device is connected (used by print_status)
any_device_connected() {
    local mac
    while read -r _ mac _; do
        if device_connected "$mac"; then
            return 0
        fi
    done < <(bluetoothctl devices)
    return 1
}

# Returns 0 if device is paired
device_paired() {
    local mac="$1"
    bluetoothctl info "$mac" | grep -q "Paired: yes"
}

# Returns 0 if device is trusted
device_trusted() {
    local mac="$1"
    bluetoothctl info "$mac" | grep -q "Trusted: yes"
}

# Toggles device connection (with notifications)
toggle_connection() {
    local mac="$1"
    if device_connected "$mac"; then
        if bluetoothctl disconnect "$mac" &>/dev/null; then
            notify -t 2000 "Bluetooth" "Disconnected"
        else
            notify -u critical "Bluetooth" "Failed to disconnect"
        fi
    else
        if bluetoothctl connect "$mac" &>/dev/null; then
            notify -t 2000 "Bluetooth" "Connected"
        else
            notify -u critical "Bluetooth" "Failed to connect"
        fi
    fi
    sleep 1
    device_menu "$mac"
}

# Toggles device paired state
toggle_paired() {
    local mac="$1"
    if device_paired "$mac"; then
        if bluetoothctl remove "$mac"; then
            show_menu
        else
            notify -u critical "Bluetooth" "Failed to remove device"
            device_menu "$mac"
        fi
    else
        if bluetoothctl pair "$mac"; then
            notify -t 2000 "Bluetooth" "Paired"
        else
            notify -u critical "Bluetooth" "Pairing failed"
        fi
        device_menu "$mac"
    fi
}

# Toggles device trust state
toggle_trust() {
    local mac="$1"
    if device_trusted "$mac"; then
        if ! bluetoothctl untrust "$mac"; then
            notify -u critical "Bluetooth" "Failed to untrust"
            return 1
        fi
    else
        if ! bluetoothctl trust "$mac"; then
            notify -u critical "Bluetooth" "Failed to trust"
            return 1
        fi
    fi
    device_menu "$mac"
}

# --------------------------
# Menu functions
# --------------------------

# Device submenu
device_menu() {
    local mac="$1"
    local device_name
    device_name=$(bluetoothctl info "$mac" | grep "Name:" | cut -d ' ' -f 2-)
    [[ -z "$device_name" ]] && device_name="$mac"

    # Build options
    local connected_status="Connected: no"
    device_connected "$mac" && connected_status="Connected: yes"

    local paired_status="Paired: no"
    device_paired "$mac" && paired_status="Paired: yes"

    local trusted_status="Trusted: no"
    device_trusted "$mac" && trusted_status="Trusted: yes"

    local remove_label="Remove Device"

    local options="$connected_status\n$paired_status\n$trusted_status\n$remove_label\n$divider\n$goback\nExit"

    # Open rofi menu
    local chosen
    chosen="$(echo -e "$options" | $rofi_command "$device_name")"

    case "$chosen" in
        "" | "$divider")
            ;;
        "$connected_status")
            toggle_connection "$mac"
            ;;
        "$paired_status")
            toggle_paired "$mac"
            ;;
        "$trusted_status")
            toggle_trust "$mac"
            ;;
        "$remove_label")
            if bluetoothctl remove "$mac"; then
                show_menu
            else
                notify -u critical "Bluetooth" "Failed to remove device"
                device_menu "$mac"
            fi
            ;;
        "$goback")
            show_menu
            ;;
        "Exit")
            exit 0
            ;;
    esac
}

# Main menu
show_menu() {
    # Build options
    if power_on; then
        local power_status="Power: on"

        # Get list of devices: display only name (no MAC)
        declare -A device_map
        local display_name
        while read -r _ mac name; do
            display_name="$name"
            device_map["$display_name"]="$mac"
        done < <(bluetoothctl devices)

        # Get controller statuses
        local pairable_status="Pairable: off"
        pairable_on && pairable_status="Pairable: on"
        local discoverable_status="Discoverable: off"
        discoverable_on && discoverable_status="Discoverable: on"

        # Build options list (device names + statuses + scan action)
        local options=""
        for d in "${!device_map[@]}"; do
            options+="$d\n"
        done
        options+="$divider\n$power_status\nScan for devices\n$pairable_status\n$discoverable_status\nExit"
    else
        local power_status="Power: off"
        local options="$power_status\nExit"
    fi

    # Open rofi menu
    local chosen
    chosen="$(echo -e "$options" | $rofi_command "Bluetooth")"

    case "$chosen" in
        "" | "$divider")
            ;;
        "$power_status")
            toggle_power
            ;;
        "Scan for devices")
            perform_scan
            show_menu
            ;;
        "$discoverable_status")
            toggle_discoverable
            ;;
        "$pairable_status")
            toggle_pairable
            ;;
        "Exit")
            exit 0
            ;;
        *)
            if [[ -n "${device_map[$chosen]}" ]]; then
                device_menu "${device_map[$chosen]}"
            fi
            ;;
    esac
}

# --------------------------
# Status output for bars
# --------------------------
print_status() {
    if power_on; then
        if any_device_connected; then
            echo "󰂱"
        else
            echo ""
        fi
    else
        echo "%{F#7f849c}󰂲"
    fi
}

# --------------------------
# Main entry point
# --------------------------
check_dependencies

case "$1" in
    --status)
        print_status
        ;;
    --help)
        cat <<EOF
Usage: $0 [--status] [--help]

Options:
  --status    Print a short status string (for status bars)
  --help      Show this help message
EOF
        ;;
    *)
        show_menu
        ;;
esac