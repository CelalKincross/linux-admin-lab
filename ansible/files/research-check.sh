#!/bin/bash

LOGTAG="research-check"
TARGET="/research"

if mountpoint -q "$TARGET"; then
	logger -t "$LOGTAG" "OK: $TARGET is mounted and accessible"
else
	logger -t "$LOGTAG" "FAIL: $TARGET is NOT mounted"
	exit 1
fi

