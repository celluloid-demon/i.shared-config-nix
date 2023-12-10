#!/bin/bash
# ---------------------------------------------------------------------------
# stdgethome.sh - Get the $HOME directory for another user.

# This is an stdutils.sh library.

# Read the manual on stdutils.sh for more info on what global, immutable
# variables are available to you.

# usage: gethome <desired username>

# example (as user jonathan): gethome "root"

# Revision history:
# 2015-02-21 Created
# ---------------------------------------------------------------------------

# Define functions
gethome() {
  local username="$1"

  eval echo "~$username"
}
