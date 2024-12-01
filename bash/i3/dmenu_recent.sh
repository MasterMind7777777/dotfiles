#!/bin/bash

# Define the file to store recent apps
RECENT_FILE="$HOME/.dmenu_recent"

# Get a list of recently used apps from the file
if [ -f "$RECENT_FILE" ]; then
    recent_apps=$(cat "$RECENT_FILE")
fi

# Get a list of all available apps, adding Chrome profile options
all_apps=$(echo -e "chrome work\nchrome home\n$(dmenu_path)")

# Merge them into a new list with recent apps first
merged_apps=$(echo -e "$recent_apps\n$all_apps" | awk '!seen[$0]++')

# Run dmenu to get the selected app
selected_app=$(echo -e "$merged_apps" | dmenu -nf '#F8F8F2' -nb '#282A36' -sb '#6272A4' -sf '#F8F8F2' -fn 'monospace-20' -p 'dmenu%')

# If the user selected an app, run it and update the recent apps list
if [ -n "$selected_app" ]; then
    # Check if selected app is one of the Chrome profiles
    if [ "$selected_app" == "chrome work" ]; then
        google-chrome-stable --profile-directory="Profile 3"
    elif [ "$selected_app" == "chrome home" ]; then
        google-chrome-stable --profile-directory="Default"
    else
        # Run the selected app if it's not a Chrome profile
        eval "$selected_app &"
    fi
  
    # Add this app to the top of the recent file
    echo -e "$selected_app\n$(cat "$RECENT_FILE")" > "$RECENT_FILE"
  
    # Make sure the file contains unique lines (i.e., remove duplicates while keeping the order)
    awk '!seen[$0]++' "$RECENT_FILE" > "${RECENT_FILE}.tmp" && mv "${RECENT_FILE}.tmp" "$RECENT_FILE"
fi

