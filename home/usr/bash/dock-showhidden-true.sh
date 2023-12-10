#!/bin/bash
# ---------------------------------------------------------------------------
# dock-showhidden-true.sh - Make hidden application icons transparent.

# Usage: dock-showhidden-true.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2011-08-25 Created
# ---------------------------------------------------------------------------

defaults write com.apple.Dock showhidden -bool YES
killall Dock
