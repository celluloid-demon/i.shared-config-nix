#!/bin/bash
# ---------------------------------------------------------------------------
# finder-path-view-true.sh - Enable the Path View in Finder.

# Usage: finder-path-view-true.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2011-08-25 Created
# ---------------------------------------------------------------------------

defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
killall Finder
