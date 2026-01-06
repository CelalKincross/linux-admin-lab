#!/bin/bash
#
# Pull-based snapshot backup of /research from lab-admin to lab-backup
# Node: lab-backup (backup server)
# Location: /usr/local/bin/backup-research.sh
#
# This script pulls data from lab-admin:/research over SSH
# Unlike the local backup on lab-admin, this is a pull-based backup
# where the backup server (lab-backup) initiates the transfer.
#

set -euo pipefail

SRC="yanglee@lab-admin:/research/"
BASE="/var/backups/research"
DATE="$(date +%F)"
DEST="$BASE/$DATE"
LINK="$BASE/current"
LOGTAG="research-backup"

# Ensure base directory exists
mkdir -p "$BASE"

# Build rsync options
OPTS="-a --numeric-ids --delete-delay"

# If a previous snapshot exists, link against it
if [ -L "$LINK" ] && [ -d "$(readlink -f "$LINK")" ]; then
    OPTS="$OPTS --link-dest=$(readlink -f "$LINK")"
fi

# Run backup with sudo rsync on remote side
# Note: requires yanglee@lab-admin to have NOPASSWD sudo for /usr/bin/rsync
if rsync $OPTS --rsync-path="sudo rsync" "$SRC" "$DEST"; then
    ln -sfn "$DEST" "$LINK"
    logger -t "$LOGTAG" "OK: Snapshot created at $DEST"
else
    logger -t "$LOGTAG" "FAIL: rsync error"
    exit 1
fi

# Retention: keep last 7 snapshots
cd "$BASE"

ls -1d 20* 2>/dev/null | sort | head -n -7 | while read old; do
    rm -rf "$old"
    logger -t "$LOGTAG" "INFO: Removed old snapshot $old"
done

exit 0
