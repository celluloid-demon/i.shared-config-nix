#!/bin/bash
# ---------------------------------------------------------------------------
# flush-dns-cache.lion.sh - Flush DNS cache in OS X 10.8 Mountain Lion.

# Usage: flush-dns-cache.lion.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2012-07-18 Created
# ---------------------------------------------------------------------------

sudo killall -HUP mDNSResponder
