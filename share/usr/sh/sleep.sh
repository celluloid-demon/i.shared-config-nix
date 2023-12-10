#!/bin/sh
# ---------------------------------------------------------------------------
# sleep.sh - [Enter description here.]

# Usage: sleep.sh

# Revision history:
# 2015-10-01 Created by Jonathan Dudrey
# ---------------------------------------------------------------------------

# Define functions
main() {
  set_sleep
}

set_sleep() {
  sleep 60

  pmset sleepnow
}

# Main logic
main
