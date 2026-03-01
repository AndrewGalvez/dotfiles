#!/bin/bash

playerctl --player=spotify --follow metadata --format '{{title}} - {{artist}}' | while read line; do
  dunstify -a "Spotify" "Now Playing" "$line" \
    --icon=spotify-launcher \
    -A "focus,Focus" | \
  while read action; do
    [ "$action" = "focus" ] && hyprctl dispatch focuswindow class:spotify
  done &
done
