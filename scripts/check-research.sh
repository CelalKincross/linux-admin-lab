#!/bin/bash
#
# Health check for /research mount availability
# Node: lab-compute
# Location: /usr/local/bin/check-research.sh
#

LOGTAG="research-check"
TARGET="/research"

if mountpoint -q "$TARGET"; then
    logger -t "$LOGTAG" "OK: $TARGET is mounted and accessible"
    exit 0
else
    logger -t "$LOGTAG" "FAIL: $TARGET is NOT mounted"
    exit 1
fi
