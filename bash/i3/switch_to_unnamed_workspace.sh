#!/bin/bash
# File: switch_to_unnamed_workspace.sh

# Define named workspaces to exclude
exclude=("web" "terminal" "slack" "remote")

# Fetch the list of workspaces
json=$(i3-msg -t get_workspaces)
workspaces=$(echo $json | jq -r '.[].name')

# Find the currently focused workspace
current=$(echo $json | jq -r 'map(select(.focused==true)) | .[0].name')

# Create an array to hold unnamed workspaces
unnamed_workspaces=()

# Filter out named workspaces
for workspace in $workspaces; do
  include=true
  for exc in "${exclude[@]}"; do
    if [[ $workspace == *"$exc"* ]]; then
      include=false
      break
    fi
  done
  if [ "$include" = true ]; then
    unnamed_workspaces+=($workspace)
  fi
done

# If you're in a named workspace, switch to the first unnamed workspace
if [[ " ${exclude[@]} " =~ " ${current} " ]]; then
  i3-msg workspace "${unnamed_workspaces[0]}"
  exit 0
else
  # Find the next unnamed workspace to focus on
  length=${#unnamed_workspaces[@]}
  for (( i=0; i<$length; i++ )); do
    if [ "${unnamed_workspaces[$i]}" == "$current" ]; then
      next=$(( (i + 1) % $length ))
      i3-msg workspace "${unnamed_workspaces[$next]}"
      exit 0
    fi
  done
  # If you are in an unnamed workspace that is not in the list for some reason, switch to the first unnamed workspace
  i3-msg workspace "${unnamed_workspaces[0]}"
  exit 0
fi
