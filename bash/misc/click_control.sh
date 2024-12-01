#!/bin/bash

STATE_FILE="/tmp/click_state"
PID_FILE="/tmp/click_pid"

# Function to perform the clicking
click_loop() {
  while [ "$(cat $STATE_FILE)" = "on" ]; do
    xdotool click 1
    sleep 0.001 # Adjust the interval as needed
  done
}

# Toggle clicking on/off
if [ -f "$STATE_FILE" ]; then
  if [ "$(cat $STATE_FILE)" = "off" ]; then
    echo "on" > "$STATE_FILE"
    click_loop &
    echo $! > "$PID_FILE"
  else
    echo "off" > "$STATE_FILE"
    if [ -f "$PID_FILE" ]; then
      kill $(cat "$PID_FILE")
      rm "$PID_FILE"
    fi
  fi
else
  echo "on" > "$STATE_FILE"
  click_loop &
  echo $! > "$PID_FILE"
fi

