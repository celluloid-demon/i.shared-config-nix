#!/bin/bash
# ---------------------------------------------------------------------------
# flush-dns-cache.tiger.sh - Flush DNS cache in OS X 10.4 Tiger.

# Usage: flush-dns-cache.tiger.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2012-07-18 Created
# ---------------------------------------------------------------------------

lookupd -flushcache
