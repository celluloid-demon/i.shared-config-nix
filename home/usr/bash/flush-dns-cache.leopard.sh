#!/bin/bash
# ---------------------------------------------------------------------------
# flush-dns-cache.leopard.sh - Flush DNS cache in OS X 10.5 Leopard.

# Usage: flush-dns-cache.leopard.sh

# Revision history:
# 2015-01-03 Minor formatting corrections
# 2012-07-18 Created
# ---------------------------------------------------------------------------

dscacheutil -flushcache
