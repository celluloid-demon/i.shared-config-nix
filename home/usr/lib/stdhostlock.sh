#!/bin/bash
# ---------------------------------------------------------------------------
# stdhostlock.sh - Simple lock/ban management for scripts shared between
# multiple hosts.

# This is mostly a temporary, catch-all error implementation to be used by
# scripts.

# This is an stdutils.sh library.

# Configuration file: hostlocktb

# hostlocktb syntax: <scriptname> <ban | lock> <hostname>

# Note: The sequence of hostlocktb flags cannot be changed.

# A note on scripts sourced in the command-line: The hostlock function is
# designed to exit a script, which normally runs in a child process, if it
# matches an error condition from its database, hostlocktb. However, some
# commands, such as xbrowse, work by being sourced directly via the command-
# line, and thus would not spawn a child process that could safely be exited.
# You have been warned!

# Usage: hostlock

# See example function hl_sample_main() for further info.

# Revision history:
# 2015-02-25 Created
# ---------------------------------------------------------------------------

hostlock() {
  local config="$HOME/usr/etc/hostlocktb"
  local flag=($(grep "$(basename $0)" "$config"))

  hl_flag1
  hl_flag2
  hl_flag3
}

hl_flag1() { # error-catching for <scriptname>
  if [ "${flag[0]}" != "$(basename $0)" ]; then
    flag[0]="(null)"
    hl_err "Command \"$(basename $0)\" not found in $(basename $config)." "${flag[0]}"
  fi
}

hl_flag2() { # error-catching for <ban | lock>
  if [ "${flag[1]}" != "ban" -a "${flag[1]}" != "lock" ]; then
    hl_err "<ban | lock> flag missing for command \"$(basename $0)\" in $(basename $config)." "${flag[1]}"
  fi
}

hl_flag3() { # error-catching for <hostname>
  if [ "${flag[1]}" == "ban" -a "${flag[2]}" == "$(hostname)" ]; then
    hl_err "<hostname> flag matches output of hostname ($(hostname))." "${flag[2]}"
  elif [ "${flag[1]}" == "lock" -a "${flag[2]}" != "$(hostname)" ]; then
    hl_err "<hostname> flag does not match output of hostname ($(hostname))." "${flag[2]}"
  fi
}

hl_err() {
  local splash="$HOME/usr/etc/splash/catbug"

  cat "$splash"

  exit
}

hl_err.old() {
  # Plug this back in if you need more verbose output.
  # Usage: hl_err <reason> <value given>

  local p="[$(basename $0)]"

  echo "$p ERROR: Failed to parse $(basename $config)."
  echo "$p Reason: $1"
  echo "$p Value given: $2"
  echo "$p Aborting."

  exit
}

hl_sample_main() {
  # Step 1: hostlock
  hostlock

  # Step 2: Main logic
  echo "[hostlock] Doing stuff..."
  echo "[hostlock] Done!"
}
