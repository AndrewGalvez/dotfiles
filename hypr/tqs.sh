#!/bin/bash

if pgrep -x "qs|quickshell" > /dev/null; then
    pkill -x "qs|quickshell"
    echo "Quickshell stopped"
else
    qs &
    echo "Quickshell started"
fi
