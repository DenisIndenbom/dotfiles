#!/bin/sh

case "$1" in
  --float)
    class='alacritty_floating'
    ;;
  --full)
    class='alacritty_fullscreen'
    ;;
  *)
    exec alacritty "$@"
    ;;
esac

shift
exec alacritty --class "$class" "$@"