#!/bin/bash

tmp="/tmp/spotify-cover.jpg"

playerctl --player=spotify --follow metadata \
  --format '{{title}} - {{artist}}|{{mpris:artUrl}}' | \
while IFS="|" read line art; do
  if [[ "$art" == http* ]]; then
    curl -sL "$art" -o "$tmp"
    icon="$tmp"
  else
    icon="${art#file://}"
  fi

  dunstify -t 5000 -a "Spotify" "Now Playing" "$line" \
    --icon="$icon" \
    -A "focus,Focus" | \
  while read action; do
    [ "$action" = "focus" ] && hyprctl dispatch focuswindow class:spotify
  done &
done
