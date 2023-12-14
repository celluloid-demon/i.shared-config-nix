#!/bin/bash

# Exit on error
set -e

# Set working directory so we know where '.sync' folder is (for running from cron / as KDE autostart script)
SCPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCPT_DIR="$(dirname "$SCPT_PATH")"
cd "$SCPT_DIR"

# Declare vars
config="$HOME/.config/rslsync.conf"

# Start resilio sync in configuration mode
rslsync --config "$config"
