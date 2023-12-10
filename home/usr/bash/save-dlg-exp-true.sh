#!/bin/bash
# ---------------------------------------------------------------------------
# save-dlg-exp-true.sh - Set the Expanded Save Dialogue as default.

# Usage: save-dlg-exp-true.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2011-08-25 Created
# ---------------------------------------------------------------------------

defaults write -g NSNavPanelExpandedStateForSaveMode -bool TRUE
