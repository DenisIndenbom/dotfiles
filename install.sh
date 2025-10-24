#!/usr/bin/env bash

packages="\
python-setuptools polybar rofi alacritty picom dunst \
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

# cp -r ./.config ~/
# find ~/.config/scripts/ -type f -exec chmod +x {} +
# cp ~/.i3/config config_backup
# cp ./.i3/config ~/.i3/config
# cp ./.config/wallpapers/mocha.png ~/.wall