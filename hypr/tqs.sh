#!/bin/bash

if pgrep -x quickshell > /dev/null; then
    pkill -x quickshell
    echo "Quickshell stopped"
else
    quickshell &
    echo "Quickshell started"
fi
