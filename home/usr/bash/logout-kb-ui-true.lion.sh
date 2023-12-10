#!/bin/bash
# ---------------------------------------------------------------------------
# logout-kb-ui-true.lion.sh - Restore tab and spacebar keys in Logout Window on
# OS X 10.7 Lion.

# Usage: logout-kb-ui-true.lion.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2012-05-14 Created
# ---------------------------------------------------------------------------

sudo defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
