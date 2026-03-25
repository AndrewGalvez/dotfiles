#!/bin/bash
sleep "$1"
SOUND="${3:-/home/turtle/.config/quickshell/alarm/alarm.mp3}"
(while true; do ffplay -nodisp -autoexit "$SOUND" 2>/dev/null; done) &
SOUND_PID=$!
ID=$(notify-send -p -u critical '⏰ Time up!' "$2")
while makoctl list | grep -q "\"$ID\""; do sleep 0.5; done
kill $SOUND_PID 2>/dev/null
