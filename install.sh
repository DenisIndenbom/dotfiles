#!/bin/sh

packages="\
python-setuptools polybar rofi alacritty picom-ftlabs-git dunst \
gtk3 gtk4 gtk-engine-murrine gnome-themes-extra \
pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils pamixer \
feh brightnessctl bluez-utils i3lock-color \
yad xclip stalonetray maim gpick imagemagick ffmpeg \
ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-sarasa-gothic ttf-roboto \
mpd mpdris2 ncmpcpp playerctl \
polkit-gnome xfce4-power-manager \
libnotify notify-send-py \
xdo xsettingsd \
python3 python-gobject yad"

yay -S $packages --needed

