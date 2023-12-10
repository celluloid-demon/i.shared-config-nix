#!/bin/bash
# ---------------------------------------------------------------------------
# lockfile1.sh - Lockfile implementation that uses a PID.

# Here's an implementation that uses a lockfile and echoes a PID into it. This
# serves as a protection if the process is killed before removing the pidfile.

# The trick here is the kill -0 which doesn't deliver any signal but just
# checks if a process with the given PID exists. Also the call to trap will
# ensure that the lockfile is removed even when your process is killed (except
# kill -9).

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2015-01-03 Re-written into functions
# 2014-12-12 Created
# ---------------------------------------------------------------------------

# A couple of nice things about this implementation:
#   I:  It cleans up if the process is interrupted (except kill-9), and
#   II: It reclaims the orphaned lockfile if interrupted with a kill -9.

# This doesn't do one thing:
#   I:  It doesn't check, then create if missing, a lockfile in a single
#       atomic action.

LOCKFILE="process.lock"

test_lockfile() { # Sample main logic using lockfile functions
  check_lockfile_status

  create_lockfile

  # Main logic goes here:
  echo "Waiting for five (5) seconds..."

  sleep 5

  remove_lockfile

  echo "Done!"
}

check_lockfile_status() {
  if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
      echo "Already running."
      exit
  fi
}

create_lockfile() {
  # Make sure the lockfile is removed when we exit and then claim it
  trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
  echo $$ > ${LOCKFILE}
}

remove_lockfile() {
  rm -f ${LOCKFILE}
}

# test_lockfile
