#!/bin/bash

# Setting the DISPLAY variable
export DISPLAY=:0

# Get the current keyboard layout
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# Toggle the layout and write to the file
if [ "$current_layout" == "us" ]; then
    setxkbmap ru  # Change layout to Russian
    echo "MOSCOW" > /home/mastermind/temp/.time_toggle  # Write to the file
elif [ "$current_layout" == "ru" ]; then
    setxkbmap us  # Change layout to US
    echo "ARGENTINA" > /home/mastermind/temp/.time_toggle  # Write to the file
fi

