#!/bin/bash
# ---------------------------------------------------------------------------
# ical-debug-menu-true.lion.sh - Enable Debug menu in iCal on OS X 10.7 Lion.

# Usage: ical-debug-menu-true.lion.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2012-02-21 Created
# ---------------------------------------------------------------------------

defaults write com.apple.iCal IncludeDebugMenu 1
