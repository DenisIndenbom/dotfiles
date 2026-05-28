#!/bin/bash
set -e  # Stop on any error

echo "========================================"
echo " Starting Btrfs post-install setup..."
echo "========================================"

# 1. Create and activate Btrfs swap file
echo "Creating swap file on @swap subvolume..."
btrfs filesystem mkswapfile --size 8G /swap/swapfile
swapon /swap/swapfile
echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab
echo "Swap file created and activated."

# 2. Configure Snapper for root and home
echo "Setting up Snapper configurations..."
snapper -c root create-config /
snapper -c home create-config /home
echo "Snapper configs created."

# 3. Enable automatic maintenance services
echo "Enabling Snapper timeline and cleanup timers..."
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
echo "Enabling monthly Btrfs scrub timer..."
systemctl enable --now btrfs-scrub@-.timer

# 4. Enable grub-btrfsd daemon (auto-updates GRUB with snapshots)
echo "Enabling grub-btrfsd service to add snapshots to GRUB menu..."
systemctl enable --now grub-btrfsd

# 5. Add Russian keyboard layout
echo "Configuring Russian keyboard layout..."
# Set console keymap to Russian (Unicode)
localectl set-keymap ru
# Set X11 layout: US as primary, RU as secondary, with Alt+Shift to toggle
localectl set-x11-keymap us,ru "" "" grp:alt_shift_toggle
echo "Russian keyboard layout added (Alt+Shift to switch)."

echo "========================================"
echo " Post-install setup complete!"
echo "========================================"