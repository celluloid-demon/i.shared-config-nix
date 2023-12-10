#!/bin/bash
# ---------------------------------------------------------------------------
# 2d-dock-true.sh - Enable 2D dock.

# Usage: 2d-dock-true.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2013-11-20 Created
# ---------------------------------------------------------------------------

defaults write com.apple.dock no-glass -boolean YES
killall Dock
