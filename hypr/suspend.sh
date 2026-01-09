#!/bin/bash

echo "Suspend? type yes to suspend or press enter"
read confirm

if [ $confirm = "yes" ]; then
  systemctl suspend
  exit
else
  echo "Okay."
fi
