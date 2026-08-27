#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

sbctl create-keys
for IMG in $(sbctl verify | awk '{ if (NR > 1) print $2 }'); do sbctl sign -s ${IMG}; done;
sbctl enroll-keys -m