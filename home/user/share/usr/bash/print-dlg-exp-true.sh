#!/bin/bash
# ---------------------------------------------------------------------------
# print-dlg-exp-true.sh - Set the Expanded Print Dialogue as default.

# Usage: print-dlg-exp-true.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2011-08-25 Created
# ---------------------------------------------------------------------------

defaults write -g PMPrintingExpandedStateForPrint -bool TRUE
