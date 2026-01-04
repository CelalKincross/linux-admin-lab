# Day 5 — systemd Operations & Backup Automation

**Date**: 2026-01-04
**Focus**: Operational automation using systemd services, timers, and rsync-based backups
**Theme**: Turn a working system into a reliable, repeatable, self-healing system

---

## Overview

Day 5 focused on operational automation on single nodes using native Linux tooling:
- systemd services (oneshot health checks)
- systemd timers (replacing cron)
- rsync-based backups with snapshot-style retention
- Restore testing and validation

**No orchestration (Ansible) yet by design** - first understand what's being automated.

---

## Part 1-3: systemd Health Check (Compute Node)

### Objective

Create and validate a custom systemd service on **lab-compute** to verify availability of shared research storage (`/research`) and log results in a structured, auditable way.

This simulates a real operational requirement: detecting shared filesystem availability from the consumer's perspective.

### Design Decisions

**Service runs on lab-compute, not lab-admin**
- Compute nodes consume NFS storage
- Health checks must reflect local dependency state

**Oneshot service**
- Executes once per invocation
- Returns meaningful exit codes
- Status shows `inactive (dead)` after successful run (this is correct)

**Logging via journald**
- Uses `logger` with dedicated tag (`research-check`)
- Separates service lifecycle logs from operational signal

**No data modification**
- Read-only health verification
- Safe to run repeatedly

### Components Created

**Health Check Script**: `/usr/local/bin/check-research.sh`

```bash
#!/bin/bash

LOGTAG="research-check"
TARGET="/research"

if mountpoint -q "$TARGET"; then
    logger -t "$LOGTAG" "OK: $TARGET is mounted and accessible"
    exit 0
else
    logger -t "$LOGTAG" "FAIL: $TARGET is NOT mounted"
    exit 1
fi
```

**systemd Service Unit**: `/etc/systemd/system/research-health.service`

```ini
[Unit]
Description=Check availability of /research storage
After=remote-fs.target
Wants=remote-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-research.sh

[Install]
WantedBy=multi-user.target
```

**systemd Timer Unit**: `/etc/systemd/system/research-health.timer`

```ini
[Unit]
Description=Run research storage health check periodically

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
AccuracySec=30s

[Install]
WantedBy=timers.target
```

### Validation & Testing

**Normal operation** (automount enabled):
- Accessing `/research` triggers systemd automount
- NFS mounts on demand
- Service logs: `OK: /research is mounted and accessible`

**Failure simulation** (automount disabled):
- `research.automount` masked
- NFS unmounted
- Service correctly logs: `FAIL: /research is NOT mounted`
- systemd reports service failure due to non-zero exit code

This confirms:
- Correct interaction with systemd automount
- Proper exit-code handling
- Accurate failure detection when safety mechanisms are disabled

### Commands Used

```bash
# Enable and start timer
sudo systemctl daemon-reload
sudo systemctl enable --now research-health.timer

# Verify timer is active
systemctl list-timers | grep research

# View logs
journalctl -t research-check --no-pager
journalctl -u research-health.service --no-pager

# Manual test
sudo systemctl start research-health.service
sudo systemctl status research-health.service
```

---

## Part 4: Automated Local Backups (Admin Node)

### Objective

Back up authoritative research data safely and automatically from **lab-admin** (the storage server).

### Design Decisions

**Node**: lab-admin (not compute nodes)
- Backups belong where data originates
- lab-admin is the authoritative storage source
- Compute nodes should never back up shared storage

**Destination**: `/var/backups/research` (local to lab-admin)
- Root-only access (`chmod 700`)
- Protects research data
- Standard ops practice

**Tool**: rsync
- Incremental, idempotent
- Well-understood, reliable
- Efficient for regular backups

**Scheduling**: systemd timer (not cron)
- systemd knows dependencies
- Logs are centralized
- Failures are visible
- Execution is deterministic

### Important Design Correction

**Mountpoint checks are incorrect on storage servers**
- `mountpoint /research` checks if something is mounted *at* that path
- On the NFS server, `/research` is a local directory, NOT a mount point
- Correct guard is directory existence: `[ -d /research ]`
- **Scripts must be role-aware**: compute nodes check mounts, storage servers check directories

### Components Created

**Initial Backup Script**: `/usr/local/bin/backup-research.sh` (v1)

```bash
#!/bin/bash

SRC="/research/"
DEST="/var/backups/research/"
LOGTAG="research-backup"

# Correct check for storage server (not mountpoint)
if [ ! -d "$SRC" ]; then
    logger -t "$LOGTAG" "FAIL: /research directory missing"
    exit 1
fi

rsync -a --numeric-ids --delete-delay "$SRC" "$DEST"
RC=$?

if [ $RC -eq 0 ]; then
    logger -t "$LOGTAG" "OK: Backup completed successfully"
    exit 0
else
    logger -t "$LOGTAG" "FAIL: rsync exited with code $RC"
    exit $RC
fi
```

**systemd Service Unit**: `/etc/systemd/system/research-backup.service`

```ini
[Unit]
Description=Backup /research to local storage
After=remote-fs.target
Wants=remote-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-research.sh

[Install]
WantedBy=multi-user.target
```

**systemd Timer Unit**: `/etc/systemd/system/research-backup.timer`

```ini
[Unit]
Description=Run research backup periodically

[Timer]
OnBootSec=3min
OnUnitActiveSec=15min
AccuracySec=1min

[Install]
WantedBy=timers.target
```

---

## Part 5: Snapshot-Style Backups, Retention, Restore

### The Problem

Initial backup approach:
```
/research → /var/backups/research
```

This gives you:
- ✅ Latest state
- ❌ No history
- ❌ No protection from accidental deletion yesterday

### The Solution (Simple Snapshots)

Keep dated snapshots:
```
/var/backups/research/
├── current/          → symlink to latest snapshot
├── daily-2026-01-04/
├── daily-2026-01-03/
├── daily-2026-01-02/
```

This mimics:
- ZFS snapshots
- Borg-style backups
- Enterprise backup layouts

...but using plain rsync.

### Snapshot Approach

**Key technique**: `rsync --link-dest`
- Hard-links unchanged files to previous snapshot
- Saves space (unchanged files point to same inode)
- Gives point-in-time views
- Each snapshot appears as a complete copy

**Frequent refresh via timer**: Every 15 minutes
- Updates `daily-YYYY-MM-DD` throughout the day
- All runs on same day update the same snapshot directory
- Next day creates new snapshot directory

### Final Backup Script

**Updated Script**: `/usr/local/bin/backup-research.sh` (v2 - snapshot-aware)

```bash
#!/bin/bash
#
# Snapshot-style backup of /research
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
```

### Retention Policy

**Keep last 7 daily snapshots**
```bash
find "$BASE" -maxdepth 1 -type d -name "daily-*" | sort -r | tail -n +8 | xargs -r rm -rf
```

- Keeps newest 7 snapshots
- Deletes older ones safely
- `-r` flag on `xargs` for safety (handles empty input)
- Predictable, readable

**Bug fixed during implementation**:
- Initial retention used `$DEST` instead of `$BASE`
- Variable refactor introduced this bug
- Caught and fixed during testing

### Restore Testing

**Critical principle**: *Backups are not real until a restore is tested.*

**Test procedure**:
1. Simulate accidental deletion on lab-admin:
   ```bash
   rm /research/alice-file
   ls /research  # confirm file is gone
   ```

2. Restore from snapshot:
   ```bash
   # Single file restore
   cp /var/backups/research/daily-2026-01-03/alice-file /research/

   # Or entire directory restore
   rsync -a /var/backups/research/daily-2026-01-03/ /research/
   ```

3. Verify:
   ```bash
   ls /research  # file restored successfully
   ```

**Result**: ✅ File successfully restored from snapshot

---

## Key Lessons Learned

### systemd Understanding

1. **systemd services execute locally** - scripts must exist on the node where the service runs
2. **Oneshot services exit by design** - `inactive (dead)` can indicate success
3. **systemd automount masks failure states intentionally** - health checks must be designed with system behavior in mind
4. **journald tags** (`logger -t`) are often more useful than unit logs alone

### Timer Scheduling

5. **OnBootSec vs OnUnitActiveSec**:
   - `OnBootSec=2min`: First run 2 minutes after boot (prevents boot chaos)
   - `OnUnitActiveSec=5min`: Run again 5 minutes after last run (interval-based)
6. **Why timers > cron**:
   - systemd knows dependencies
   - Logs centralized in journald
   - Failures visible via `systemctl status`
   - Deterministic execution

### Backup Design

7. **Node role awareness**:
   - Compute nodes: check mounts with `mountpoint -q`
   - Storage servers: check directories with `[ -d ... ]`
   - Scripts must know where they run

8. **Snapshot-style backups**:
   - `rsync --link-dest` provides efficient point-in-time copies
   - Hard links save space for unchanged files
   - Retention policies prevent unbounded growth

9. **Restore testing is mandatory**:
   - Backups without restore validation are untested
   - Simulate failure scenarios
   - Document restore procedures

---

## Day 5 Outcome

You now have:

✅ **Automated health checks**
- Custom oneshot service on compute node
- Timer-driven execution every ~5 minutes
- Structured logging with dedicated tags

✅ **Automated backups**
- rsync-based backups from authoritative source
- systemd timer scheduling (every 15 minutes)
- Proper dependency handling

✅ **Snapshot-style history**
- Daily snapshots with hard-linked files
- Space-efficient storage
- Point-in-time recovery capability

✅ **Retention policy**
- Keep last 7 daily snapshots
- Automatic cleanup of older snapshots

✅ **Proven restore procedure**
- Tested file restoration from snapshot
- Validated backup integrity

✅ **Clear separation of node roles**
- Compute nodes monitor mounts
- Storage servers perform backups

---

## References

### systemd

- **systemd.service**: [https://www.freedesktop.org/software/systemd/man/systemd.service.html](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
  Service unit configuration

- **systemd.timer**: [https://www.freedesktop.org/software/systemd/man/systemd.timer.html](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
  Timer unit configuration for scheduled tasks

- **systemd.automount**: [https://www.freedesktop.org/software/systemd/man/systemd.automount.html](https://www.freedesktop.org/software/systemd/man/systemd.automount.html)
  Automount unit configuration

- **systemctl**: [https://www.freedesktop.org/software/systemd/man/systemctl.html](https://www.freedesktop.org/software/systemd/man/systemctl.html)
  Control systemd system and service manager

### Logging

- **journalctl**: [https://man7.org/linux/man-pages/man1/journalctl.1.html](https://man7.org/linux/man-pages/man1/journalctl.1.html)
  Query systemd journal

- **logger**: [https://man7.org/linux/man-pages/man1/logger.1.html](https://man7.org/linux/man-pages/man1/logger.1.html)
  Enter messages into system log

### Backup Tools

- **rsync**: [https://man7.org/linux/man-pages/man1/rsync.1.html](https://man7.org/linux/man-pages/man1/rsync.1.html)
  Fast, versatile file copying tool

- **rsync --link-dest**: [https://download.samba.org/pub/rsync/rsync.1#opt--link-dest](https://download.samba.org/pub/rsync/rsync.1#opt--link-dest)
  Hardlink to files in DIR when unchanged (snapshot technique)

### Filesystem Tools

- **mountpoint**: [https://man7.org/linux/man-pages/man1/mountpoint.1.html](https://man7.org/linux/man-pages/man1/mountpoint.1.html)
  Check if directory is a mount point

---

**Status**: ✅ Day 5 Complete (2026-01-04)

**Next**: Day 6 - Ansible Configuration Management
