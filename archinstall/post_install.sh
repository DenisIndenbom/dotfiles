#!/bin/bash
set -euo pipefail

echo "Creating Snapper configs..."
for conf in root home; do
    if ! snapper -c "$conf" list &>/dev/null; then
        snapper -c "$conf" create-config "/${conf#home}"
    fi
done

echo "Starting Snapper timers..."
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
systemctl enable --now btrfs-scrub@-.timer

echo "Enabling grub-btrfsd..."
systemctl enable --now grub-btrfsd

echo "Remaking GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

localectl set-keymap us
localectl set-x11-keymap us,ru "" "" grp:alt_shift_toggle

echo "Post-install script done."