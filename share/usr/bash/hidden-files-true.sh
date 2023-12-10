#!/bin/bash
# ---------------------------------------------------------------------------
# hidden-files-true.sh - Enable showing "dot files" on a Mac system.

# Usage: hidden-files-true.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2013-01-18 Created
# ---------------------------------------------------------------------------

defaults write com.apple.finder AppleShowAllFiles TRUE

killall Finder
