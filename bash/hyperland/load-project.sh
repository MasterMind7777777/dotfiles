#!/bin/bash

# =============================================================================
# Script: load-project.sh
# Description: Sets up the Rusty Finance Tracker project environment
# Author: [Your Name]
# Date: [Date]
# =============================================================================

# ----------------------------- Configuration ----------------------------------

# Terminal Emulator
TERMINAL="kitty"  # Using Kitty as the terminal emulator

# Workspaces
WORKSPACE_BACKEND=8
WORKSPACE_FRONTEND=2
WORKSPACE_RUNNERS=5

# Window Titles (Used for identifying windows in Hyperland)
TITLE_BACKEND="nvim_backend"
TITLE_FRONTEND="nvim_frontend"
TITLE_RUNNER_BACK="runner_back"
TITLE_RUNNER_FRONT="runner_front"

# Sleep Duration (Adjust if necessary)
SLEEP_DURATION=1  # seconds

# ----------------------------- Functions --------------------------------------

# Function to open nvim in a specific directory and assign to a workspace
open_nvim_window() {
    local dir="$1"
    local title="$2"
    local workspace="$3"

    # Launch Kitty with nvim
    $TERMINAL --title "$title" --directory "$dir" zsh -c "nvim ." &

    # Allow some time for the window to open
    sleep "$SLEEP_DURATION"

    # Move the window to the specified workspace using hyprctl
    hyprctl dispatch movetoworkspace "$workspace,title:$title"
}

# Function to open a terminal in a specific directory and assign to a workspace
open_terminal_window() {
    local dir="$1"
    local title="$2"
    local workspace="$3"

    # Launch terminal in the specified directory
    $TERMINAL --title "$title" --directory "$dir" zsh &

    # Allow some time for the window to open
    sleep "$SLEEP_DURATION"

    # Move the window to the specified workspace using hyprctl
    hyprctl dispatch movetoworkspace "$workspace,title:$title"
}

# ----------------------------- Main Script ------------------------------------

# Validate directory argument
if [[ -z "$1" ]]; then
    echo "Error: No project directory provided."
    echo "Usage: $0 <project_directory>"
    exit 1
fi

PROJECT_DIR="$1"

# Check if the directory exists
if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: Directory '$PROJECT_DIR' does not exist."
    exit 1
fi

# Subdirectories
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

# Check if backend and frontend directories exist
if [[ ! -d "$BACKEND_DIR" || ! -d "$FRONTEND_DIR" ]]; then
    echo "Error: Missing 'backend' or 'frontend' directories in '$PROJECT_DIR'."
    exit 1
fi

# Open nvim for backend on workspace 8
open_nvim_window "$BACKEND_DIR" "$TITLE_BACKEND" "$WORKSPACE_BACKEND"

# Open nvim for frontend on workspace 2
open_nvim_window "$FRONTEND_DIR" "$TITLE_FRONTEND" "$WORKSPACE_FRONTEND"

# Open terminal for backend runner on workspace 5
open_terminal_window "$BACKEND_DIR" "$TITLE_RUNNER_BACK" "$WORKSPACE_RUNNERS"

# Open terminal for frontend runner on workspace 5
open_terminal_window "$FRONTEND_DIR" "$TITLE_RUNNER_FRONT" "$WORKSPACE_RUNNERS"

# Optional: Switch to a default workspace after setup
# hyprctl dispatch workspace 1

echo "Rusty Finance Tracker environment setup complete."
