
#!/bin/bash

# Debug log file
debug_log="/home/mastermind/bash/notes/debug.log"

# Log message function
log() {
    echo "$(date) - $1" >> $debug_log
}

log "Script started."

# Check if a direction parameter is provided
if [ -z "$1" ]; then
    log "No direction provided."
    echo "Usage: $0 [left|right|up|down]"
    exit 1
fi

# Direction to move focus
direction="$1"
log "Direction: $direction"

# Validate direction
if [[ ! "$direction" =~ ^(left|right|up|down)$ ]]; then
    log "Invalid direction."
    echo "Invalid direction. Must be one of [left|right|up|down]"
    exit 1
fi

# Fetch the current workspace's floating windows with "NOTE_" in the title
all_windows=$(i3-msg -t get_tree | jq -r 'recurse(.nodes[]) | select(.window) | .name')
log "All available windows:"

# Log each available window title
while read -r title; do
    log "Window Title: $title"
done <<< "$all_windows"

# Reset the variable 'windows' for subsequent use
windows=$(i3-msg -t get_tree | jq -r 'recurse(.nodes[]) | select(.type=="floating_con") | select(.name | test("^NOTE_")) | "\(.rect.x) \(.rect.y) \(.window)"')


# Get the currently focused window's X and Y coordinates
focused_window=$(xdotool getwindowfocus)
focused_x=$(xwininfo -id $focused_window | awk '/Absolute upper-left X:/ {print $4}')
focused_y=$(xwininfo -id $focused_window | awk '/Absolute upper-left Y:/ {print $4}')
log "Focused window: $focused_window, X: $focused_x, Y: $focused_y"

# Initialize variables to hold the target window's ID and distance
closest_distance=-1
closest_window=""

# Loop through each window and calculate the distance based on direction
while read -r line; do
    x=$(echo $line | awk '{print $1}')
    y=$(echo $line | awk '{print $2}')
    id=$(echo $line | awk '{print $3}')
    log "Checking window: $id, X: $x, Y: $y"

    # Calculate "distance" based on the given direction
    distance=0
    case $direction in
        "left")  distance=$(( $focused_x - $x )) ;;
        "right") distance=$(( $x - $focused_x )) ;;
        "up")    distance=$(( $focused_y - $y )) ;;
        "down")  distance=$(( $y - $focused_y )) ;;
    esac
    log "Calculated distance: $distance"

    # Update closest window if this window is in the required direction and closer
    if [ $distance -gt 0 ] && { [ $closest_distance -eq -1 ] || [ $distance -lt $closest_distance ]; }; then
        closest_distance=$distance
        closest_window=$id
        log "New closest window: $id with distance: $distance"
    fi
done <<< "$windows"

# Focus the closest window in the given direction
if [ -n "$closest_window" ]; then
    i3-msg "[id=$closest_window] focus"
    log "Focused window: $closest_window"
else
    log "No window found in the direction $direction."
    echo "No window found in the direction $direction."
fi

log "Script ended."
