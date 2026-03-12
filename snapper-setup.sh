#!/usr/bin/env bash
set -euo pipefail

# Array of packages
packages=(
    snapper
    snap-pac
    btrfs-assistant
    grub-btrfs
)

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please install yay first."
    exit 1
fi

# Install packages if not already installed
echo "Installing packages: ${packages[*]}"
yay -S --needed --noconfirm "${packages[@]}"

# Setup snapshots for root
ROOT_SUBVOLUME="/"
if ! snapper list | grep -q "^root"; then
    echo "Creating Snapper config for root (/)"
    sudo snapper -c root create-config /
    sudo snapper -c root set-config TIMELINE_CREATE=yes
    sudo snapper -c root set-config NUMBER_CLEANUP=yes
fi

# Setup snapshots for home
HOME_DIR="/home"
if [ -d "$HOME_DIR" ]; then
    if ! snapper list | grep -q "^home"; then
        echo "Creating Snapper config for /home"
        sudo snapper -c home create-config "$HOME_DIR"
        sudo snapper -c home set-config TIMELINE_CREATE=yes
        sudo snapper -c home set-config NUMBER_CLEANUP=yes
    fi
fi

echo "Snapper setup complete. Current configurations:"
sudo snapper list