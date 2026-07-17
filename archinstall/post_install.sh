#!/bin/bash
set -euo pipefail

echo "Creating Snapper configs..."
if ! snapper -c root list &>/dev/null; then
    snapper -c root create-config /
fi
if ! snapper -c home list &>/dev/null; then
    snapper -c home create-config /
fi

echo "Starting Snapper timers..."
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
systemctl enable --now btrfs-scrub@-.timer

echo "Enabling grub-btrfsd..."
systemctl enable --now grub-btrfsd

echo "Remaking GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "Setup US/RU keyboard layout..."
localectl set-keymap us
localectl set-x11-keymap us,ru "" "" grp:alt_shift_toggle

echo "Post-install script done."