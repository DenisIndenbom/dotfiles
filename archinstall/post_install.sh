#!/bin/bash
set -e  # Stop on unexpected errors

echo "========================================"
echo " Starting Btrfs post-install setup..."
echo "========================================"

# 1. Create and activate Btrfs swap file
echo "Checking swap file on @swap subvolume..."
if [ ! -f /swap/swapfile ]; then
    echo "Creating swap file (8G)..."
    btrfs filesystem mkswapfile --size 8G /swap/swapfile
    echo "Swap file created."
else
    echo "Swap file already exists, skipping creation."
fi

# Activate swap if not already active
if swapon --show | grep -q '/swap/swapfile'; then
    echo "Swap already active."
else
    swapon /swap/swapfile
    echo "Swap activated."
fi

# Add to fstab if not already there
if ! grep -q '/swap/swapfile' /etc/fstab; then
    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab
    echo "Swap entry added to /etc/fstab."
else
    echo "Swap entry already in /etc/fstab."
fi

# 2. Configure Snapper for root and home
snapper -c root create-config /
snapper -c home create-config /home
echo "Snapper configs created."

# 3. Enable automatic maintenance services
echo "Enabling Snapper timeline and cleanup timers..."
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

echo "Enabling monthly Btrfs scrub timer..."
systemctl enable --now btrfs-scrub@-.timer

# 4. Enable grub-btrfsd daemon (auto-updates GRUB with snapshots)
echo "Enabling grub-btrfsd service..."
systemctl enable --now grub-btrfsd
echo "Remake grub config..."
grub-mkconfig -o /boot/grub/grub.cfg

# 5. Add Russian keyboard layout
echo "Configuring Russian keyboard layout..."
localectl set-keymap ru
localectl set-x11-keymap us,ru "" "" grp:alt_shift_toggle
echo "Russian keyboard layout added (Alt+Shift to switch)."

echo "========================================"
echo " Post-install setup complete!"
echo "========================================"