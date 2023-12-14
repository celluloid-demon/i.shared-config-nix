#!/bin/bash
# ---------------------------------------------------------------------------
# clear-open-with-menu.sh - Clear the "Open With" contextual menu on a Mac system.

# Usage: clear-open-with-menu.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2013-11-20 Created
# ---------------------------------------------------------------------------

/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user
