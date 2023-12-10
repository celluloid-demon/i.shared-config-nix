#!/bin/bash
# ---------------------------------------------------------------------------
# resume-false.mntnlion.sh - Disables the Resume feature in OS X Mountain
# Lion. (Unsupported! Backup, first!)

# Usage: resume-false.mntnlion.sh

# Revision history:
# 2015-01-02 Minor formatting corrections
# 2013-03-30 Created
# ---------------------------------------------------------------------------

defaults write -g ApplePersistence -bool no
