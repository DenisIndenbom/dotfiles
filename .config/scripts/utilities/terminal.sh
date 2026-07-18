#!/bin/sh

config=".config/alacritty/alacritty.toml"

case $1 in
  --float)
    alacritty --class 'alacritty_floating' --config-file "$config"
  ;;
  --full)
    alacritty --class 'alacritty_fullscreen' --config-file "$config"
  ;;
  *)
    alacritty --config-file "$config" $2 $3
  ;;
esac