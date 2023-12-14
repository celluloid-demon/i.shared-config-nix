#!/bin/bash
# ---------------------------------------------------------------------------
# 2d-dock-false.sh - Disable 2D dock.

# Usage: 2d-dock-false.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2013-11-20 Created
# ---------------------------------------------------------------------------

defaults write com.apple.dock no-glass -boolean NO
killall Dock
