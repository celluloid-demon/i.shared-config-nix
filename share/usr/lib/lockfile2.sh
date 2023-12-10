#!/bin/bash
# ---------------------------------------------------------------------------
# lockfile3.sh - Simple lockfile implementation.

# THIS is a REALLY quick and REALLY dirty way to ensure only one
# instance of a shell script is running at a time. This may or may not
# be an issue, depending on how it's used, but there's a race condition
# between testing for the lock and creating it, so that two scripts
# could both be started at the same time. If one terminates first, the
# other will stay running with no lock file.
#
# This is a really simple way to do it. You still suffer the need to
# remove the lockfile manually if something goes wrong and the lockfile
# isn't deleted. (Terminating the process in the console with CTRL-c
# will tigger this.)

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2015-01-03 Re-written into functions
# 2014-12-12 Created
# ---------------------------------------------------------------------------

# This doesn't do three things:
#   I:   It doesn't cleanup if the process is interrupted, and
#   II:  It doesn't reclaim the orphaned lockfile if interrupted.
#   III: It doesn't check for, then create if missing, a lockfile in a
#        single atomic action.

LOCKFILE="process.lock"

check_lockfile() {
  if [ -f $LOCKFILE ]; then
 #if [ -e $LOCKFILE ]; then # Apparently this is also an option?
    echo "Already running."
    exit
  fi
}

create_lockfile() {
  touch $LOCKFILE
}

remove_lockfile() {
  rm $LOCKFILE
}

test_lockfile() { # Sample main logic using lockfile functions
  check_lockfile

  create_lockfile

  # Main logic goes here:
  sleep 5

  remove_lockfile

  echo "Done!"
}

# test_lockfile
