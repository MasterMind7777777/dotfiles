#!/usr/bin/env bash
set -euo pipefail

# Send a notification with an action that, when clicked,
# opens a terminal at /home using Kitty (with fallbacks).

open_terminal() {
  if command -v kitty >/dev/null 2>&1; then
    nohup kitty --single-instance --instance-group keepalive --directory=/home >/dev/null 2>&1 &
  elif command -v wezterm >/dev/null 2>&1; then
    nohup wezterm start --cwd /home >/dev/null 2>&1 &
  elif command -v alacritty >/dev/null 2>&1; then
    nohup alacritty --working-directory /home >/dev/null 2>&1 &
  elif command -v foot >/dev/null 2>&1; then
    nohup foot >/dev/null 2>&1 &
  else
    notify-send "No terminal found" "Install kitty/wezterm/alacritty/foot" || true
  fi
}

# 1) Send the notification and capture its ID
read -r NOTIF_ID < <(gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "Action Demo" 0 "dialog-information" \
  "Open terminal" "Click to open terminal at /home" \
  "['open_home','Open Terminal']" {} 20000 \
  | sed -E "s/^\(uint32 ([0-9]+),\)$/\1/")

# 2) Monitor for ActionInvoked for this ID, exit on first match
timeout 60s gdbus monitor --session --dest org.freedesktop.Notifications \
  | awk -v id="$NOTIF_ID" '
      /member=ActionInvoked/ { pending=1; next }
      pending && /uint32/ && $2==id { have_id=1; next }
      pending && have_id && /string/ {
        if ($2 ~ /\x27open_home\x27/) { exit 10 }
        exit 0
      }
    '

case $? in
  10) open_terminal ;;
  *)  ;; # no action or different action
esac

exit 0

