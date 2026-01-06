#!/bin/bash
#
# Snapshot-style backup of /research
# Node: lab-admin
# Location: /usr/local/bin/backup-research.sh
#

SRC="/research/"
BASE="/var/backups/research"
TODAY="$(date +%F)"
SNAPSHOT="$BASE/daily-$TODAY"
CURRENT="$BASE/current"
LOGTAG="research-backup"

# Ensure source exists
if [ ! -d "$SRC" ]; then
    logger -t "$LOGTAG" "FAIL: /research directory missing"
    exit 1
fi

# Ensure base backup directory exists
mkdir -p "$BASE"

# If a current snapshot exists, use it as link-dest
if [ -d "$CURRENT" ]; then
    rsync -a --numeric-ids --delete \
        --link-dest="$CURRENT" \
        "$SRC" "$SNAPSHOT"
else
    rsync -a --numeric-ids "$SRC" "$SNAPSHOT"
fi

RC=$?

if [ $RC -ne 0 ]; then
    logger -t "$LOGTAG" "FAIL: rsync exited with code $RC"
    exit $RC
fi

# Update "current" symlink
rm -f "$CURRENT"
ln -s "$SNAPSHOT" "$CURRENT"

# Retention: keep last 7 daily snapshots
find "$BASE" -maxdepth 1 -type d -name "daily-*" | sort -r | tail -n +8 | xargs -r rm -rf

logger -t "$LOGTAG" "OK: Snapshot backup completed ($SNAPSHOT)"
exit 0
