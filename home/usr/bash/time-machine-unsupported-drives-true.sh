#!/bin/bash
# ---------------------------------------------------------------------------
# time-machine-unsupported-drives-true.sh - Enable Time Machine on unsupported
# drives.

# WARNING: IF YOU VALUE THE INTEGRITY OF YOUR BACKUPS, DO NOT ENABLE
# UNSUPPORTED DRIVES FOR TIME MACHINE. THEY ARE UNSUPPORTED FOR A REASON -
# TIME MACHINE RELIES ON CERTAIN AFP FEATURES TO MAINTAIN DATA INTEGRITY, AND
# WITHOUT THEM, YOUR DATA COULD BECOME CORRUPTED.

# Usage: time-machine-unsupported-drives-true.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2011-08-25 Created
# ---------------------------------------------------------------------------

defaults write com.apple.systempreferences TMShowUnsupportedNetworkVolumes 1
