#!/bin/bash
# ---------------------------------------------------------------------------
# SyncRC - A "remote control" for backup management. SyncRC is a modal backup
# backup manager. This means there are different modes in which you interact
# with the manager. One such mode is Link Mode, at which point you're activating
# SyncLink. Another mode is RC mode, at which point you're using SyncRC.

# Usage: syncrc.sh [-h|--help]

# Revision history:
# 2014-12-13 Created
# ---------------------------------------------------------------------------

# Declare global, immutable variables
readonly ARG="$1"
readonly PROGNAME="${0##*/}"
readonly PROGTITLE="SyncRC"
readonly VERSION="0.1"

# Load functions
LIB=syncrc/lib
source $LIB/help_message.sh
source $LIB/log.sh
source $LIB/main.sh
source $LIB/misc.sh
source $LIB/mksyncdae.sh
source $LIB/parse.sh
source $LIB/std.sh
source $LIB/usage.sh
source $LIB/utils.sh

# Main logic
main
