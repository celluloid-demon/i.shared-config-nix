#!/bin/bash
# ---------------------------------------------------------------------------
# lockfile2.sh - Lockfile implementation that uses mkdir.

# For all details, see the excellent BashFAQ:
# http://mywiki.wooledge.org/BashFAQ/045

# All approaches that test the existence of "lock files" are flawed.
# Why? Because there is no way to check whether a file exists and create
# it in a single atomic action. Because of this, there is a race
# condition that WILL make your attempts at mutual exclusion break.
# Instead, you need to use mkdir.  mkdir creates a directory if it
# doesn't exist yet, and if it does, it sets an exit code. More
# importantly, it does all this in a single atomic action making it
# perfect for this scenario.

# If you want to take care of stale locks, fuser(1) comes in handy. The
# only downside here is that the operation takes about a second, so it
# isn't instant. A mutual-exclusion lock, using fuser(1), solves this
# problem.

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2015-01-03 Re-written into functions
# 2014-12-12 Created
# ---------------------------------------------------------------------------

# This does a nice thing:
#   I:  It checks, then creates if missing, a lockfile in a single atomic
#       action.

# This doesn't do two things:
#   I:  It doesn't cleanup if the process is interrupted, and
#   II: It doesn't reclaim the orphaned lockfile if interrupted.

LOCKFILE="process.lock"

create_lockfile() {
  if ! mkdir "$LOCKFILE" 2>/dev/null; then
    echo "Already running." >&2
    exit 1 # Exits the program if another instance is already found running
  fi
}

remove_lockfile() {
  # Removes the lock on the process when the program's main functions are
  # complete.

  rm -fd ${LOCKFILE}
}

test_lockfile() { # Sample main logic using lockfile functions
  create_lockfile

  # Main logic goes here:
  echo "Waiting for five (5) seconds..."

  sleep 5

  remove_lockfile

  echo "Done!"
}

# test_lockfile
