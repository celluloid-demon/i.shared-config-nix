#!/bin/bash
# ---------------------------------------------------------------------------
# backup.sh - A simple backup script.

# Wouldn't recommend putting this in the path - it's kind of volatile! Do it
# if you're confident, or if there's been work done to considerably soften it
# (preferably with options-parsing).

# This script uses rsync as its backend - unset the --dry-run option in the
# backup routine when configured.

# Usage: backup.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2014-07-29 Created
# ---------------------------------------------------------------------------

# Define functions
main() {
  local target="./"
  local destination="$HOME/Desktop/dummy/"

  backup "$target" "$destination"
}

backup() {
  local dry_run_mode="--dry-run" # comment-out when configured

  rsync -lHvrtpg --progress --delete "$dry_run_mode" "$1" "$2"
}

# Main logic
main
