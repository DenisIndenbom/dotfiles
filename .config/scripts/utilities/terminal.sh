#!/bin/sh

case $1 in
  --float)
    alacritty --app-id 'alacritty_floating'
  ;;
  --full)
    alacritty --app-id 'alacritty_fullscreen'
  ;;
  *)
    alacritty $2 $3
  ;;
esac