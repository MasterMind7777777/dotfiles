#!/bin/bash

# Log file for debugging (optional)
LOG_FILE="$HOME/logs/focus_and_move_keep_focus.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "----- $(date) -----" >> "$LOG_FILE"

# Show CopyQ
echo "Showing CopyQ window..." >> "$LOG_FILE"
copyq show

# Focus on the CopyQ window
echo "Focusing on CopyQ window..." >> "$LOG_FILE"
i3-msg '[class="copyq"] focus'

# Get connected monitors
CONNECTED_MONITORS=($(xrandr --query | grep " connected" | cut -d" " -f1))
ACTIVE_MONITOR=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')

echo "Connected monitors: ${CONNECTED_MONITORS[*]}" >> "$LOG_FILE"
echo "Active monitor: $ACTIVE_MONITOR" >> "$LOG_FILE"

# Determine the inactive monitor
INACTIVE_MONITOR=""
for MONITOR in "${CONNECTED_MONITORS[@]}"; do
    if [ "$MONITOR" != "$ACTIVE_MONITOR" ]; then
        INACTIVE_MONITOR=$MONITOR
        break
    fi
done

if [ -n "$INACTIVE_MONITOR" ]; then
    echo "Moving CopyQ to inactive monitor: $INACTIVE_MONITOR" >> "$LOG_FILE"
    i3-msg "[class=\"copyq\"] move to output $INACTIVE_MONITOR; move position center"
else
    echo "No inactive monitor found. Centering CopyQ on the current monitor." >> "$LOG_FILE"
    i3-msg "[class=\"copyq\"] move position center"
fi

# Refocus on the CopyQ window
echo "Refocusing on CopyQ window after move..." >> "$LOG_FILE"
i3-msg '[class="copyq"] focus'

echo "Completed focusing and moving CopyQ, maintaining focus." >> "$LOG_FILE"

