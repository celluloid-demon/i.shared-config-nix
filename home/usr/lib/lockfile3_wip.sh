#!/bin/bash
# ---------------------------------------------------------------------------
# lockfile4.sh - Lockfile implementation that uses mutual exclusion.

# Open a mutual exclusion lock on the file, unless another process
# already owns one. If the file is already locked by another process,
# the operation fails. This function defines a lock on a file as having
# a file descriptor open to the file. This function uses FD 9 to open a
# lock on the file.  To release the lock, close FD 9:

# exec 9>&-

# You can use it in a script like so:

# mutex /var/run/myscript.lock || { echo "Already running." >&2; exit 1; }

# If you don't care about portability (these solutions should work on
# pretty much any UNIX box), Linux' fuser(1) offers some additional
# options and there is also flock(1).

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2014-12-12 Created
# ---------------------------------------------------------------------------

LOCKFILE="process.lock"

mutex() { # Mutual exclusion lock
  local file=$1 pid pids

  exec 9>>"$file"
  { pids=$(fuser -f "$file"); } 2>&- 9>&-
  for pid in $pids; do
      [[ $pid = $$ ]] && continue

      exec 9>&-
      return 1 # Locked by a pid
  done
}

test_mutex() { # Sample main logic using mutex function
  mutex "$LOCKFILE" || { echo "Already running." >&2; exit 1; }

  # Main logic goes here:
  sleep 5

 #remove_lockfile

  echo "Done!"
}

test_mutex
