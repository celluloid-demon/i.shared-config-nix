#!/bin/bash
# ---------------------------------------------------------------------------
# Test ver. 0.1
# This is a test.

# Usage: test.sh
# ---------------------------------------------------------------------------

# Global, immutable variables
# readonly ARG1="$1"
# readonly ARG2="$2"
readonly PROGNAME="${0##*/}"
readonly PROGTITLE="Test"
readonly VERSION="0.1"

# Load functions
LIB="test/lib"
# source $LIB/help_message.sh
# source $LIB/lockfile.sh
# source $LIB/log.sh
# source $LIB/main.sh
# source $LIB/misc.sh
# source $LIB/mksyncdae.sh
source $LIB/parse.sh
# source $LIB/std.sh
# source $LIB/usage.sh
# source $LIB/utils.sh

# Define functions
main() {
  parse "$@"
}

# Main logic
main "$@"
