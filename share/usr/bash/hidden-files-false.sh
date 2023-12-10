#!/bin/bash
# ---------------------------------------------------------------------------
# hidden-files-false.sh - Disable showing "dot files" on a Mac system.

# Usage: hidden-files-false.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2013-01-18 Created
# ---------------------------------------------------------------------------

defaults write com.apple.finder AppleShowAllFiles FALSE

killall Finder
