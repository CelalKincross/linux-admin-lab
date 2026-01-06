# Day 7 - Off-Host Backup Implementation (lab-backup Node)

**Date**: 2026-01-06
**Focus**: Pull-based backup architecture with snapshot retention and systemd automation
**Theme**: Transform lab-backup from conceptual to operational - production-grade backup implementation

---

## Overview

Day 7 established lab-backup as a first-class operational node, implementing pull-based off-host backups of research data from lab-admin. This represents a critical transition from on-host backups (Day 5) to a dedicated backup infrastructure with proper separation of concerns.

**What was accomplished**:
- Configured lab-backup node with secure backup storage
- Established SSH trust model (root@lab-backup → yanglee@lab-admin)
- Implemented snapshot-style backups using rsync --link-dest
- Applied 7-day retention policy with automatic pruning
- Automated backup execution via systemd service + timer
- Addressed real operational challenges (SSH key bootstrap, permission handling)

**Architectural significance**: The backup node never mounts live research storage, implementing a clean pull-based model where the backup server controls scheduling and compromised admin nodes cannot overwrite backup history.

---

## Objectives Completed

### Part 1: Prepare lab-backup Node
- ✅ Verified identity consistency (hostname, user, sudo)
- ✅ Created backup storage layout (`/var/backups/research`)
- ✅ Set restrictive permissions (0750, root-only access)
- ✅ Confirmed NFS isolation (no `/research` mount on backup node)

**Key Decision**: Backups are privileged data - stored in root-only directories, never accessible to regular users.

### Part 2: SSH Trust Setup (Pull-Based Model)
- ✅ Generated ED25519 SSH key for root@lab-backup
- ✅ Installed public key on yanglee@lab-admin
- ✅ Verified passwordless SSH connectivity
- ✅ Tested remote data access via SSH

**Troubleshooting**: SSH key bootstrap required temporary relaxation of password authentication policy (`Match all=yes` → `Match all=no`), then restored immediately after key installation. This is standard operational practice for key deployment in hardened environments.

### Part 3: Snapshot-Style Backups with rsync
- ✅ Implemented snapshot backup script with --link-dest
- ✅ Created timestamped snapshot directories (YYYY-MM-DD format)
- ✅ Used hard-linking for space-efficient storage
- ✅ Established `current` symlink pointing to latest snapshot
- ✅ Integrated journald logging with dedicated tag (`research-backup`)

**Permission Challenge**: Initial rsync failed on `/research/project1` (Permission denied). Resolved by invoking `sudo rsync` on source host via tightly scoped sudoers rule, preserving project isolation while enabling complete backups.

### Part 4: Retention Policy
- ✅ Implemented 7-day snapshot retention
- ✅ Automated pruning of snapshots older than 7 days
- ✅ Logged all retention actions to journald
- ✅ Tested retention logic with simulated old snapshots

**Design**: Simple, defensible retention (7 daily snapshots) balancing storage capacity with recovery window.

### Part 5: systemd Automation
- ✅ Created systemd service unit (`research-backup.service`)
- ✅ Created systemd timer unit (`research-backup.timer`)
- ✅ Enabled and started timer for daily execution
- ✅ Verified automatic execution and logging
- ✅ Tested manual service invocation

**Why systemd over cron**: Integrated logging, network dependency handling, persistent execution (missed runs after reboot), better failure visibility.

---

## Architecture: 3-Node Backup Model

### Node Responsibilities

| Host | Role | Backup Involvement |
|------|------|-------------------|
| **lab-admin** | NFS server - owns `/research` | Source of authoritative data |
| **lab-compute** | NFS client - uses `/research` | No backup responsibility |
| **lab-backup** | Dedicated backup server | Pulls backups, never mounts live storage |

### Pull-Based Model (Why This Design Matters)

**Pull-based architecture**:
- lab-backup initiates connections to lab-admin
- lab-backup controls backup schedule
- lab-admin never pushes data outward

**Why pull-based is correct**:
1. **Backup server controls schedule** - centralized orchestration
2. **Compromised admin cannot overwrite backups** - security boundary
3. **Clear trust model** - backup server is authoritative
4. **Industry standard** - mirrors real production environments

**Trust model**:
- root@lab-backup has SSH key installed on yanglee@lab-admin
- yanglee@lab-admin has restricted sudo access: `/usr/bin/rsync` only
- Minimal privilege for remote execution
- Auditable via sudo logs

**Storage isolation**:
- lab-backup NEVER mounts `/research` via NFS
- Backups stored locally on lab-backup in `/var/backups/research`
- No dependency on NFS availability for backup integrity

---

## Implementation Details

### Part 1: Prepare lab-backup

**1.1 Verify Node Identity**

```bash
# On lab-backup
hostname          # Expected: lab-backup
id                # Confirm yanglee user exists
sudo whoami       # Confirm sudo access works
```

**1.2 Create Backup Storage Layout**

```bash
sudo mkdir -p /var/backups/research
sudo chown root:root /var/backups/research
sudo chmod 0750 /var/backups/research
```

**Why these permissions**:
- `0750`: Owner (root) has full access, group (root) can read, others have no access
- Backups contain all research data including restricted projects
- Regular users should never browse backup directories
- Only root can read/write backups

**1.3 Confirm NFS Isolation**

```bash
mount | grep research
# Expected: no output
```

This confirms lab-backup never mounts live research storage. This architectural decision prevents:
- Backup corruption from simultaneous mount issues
- Dependency on NFS server availability
- Accidental modification of live data

---

### Part 2: SSH Trust for Pull-Based Backups

**2.1 Design Decision: Run Backups as Root**

Backups execute as `root` on lab-backup because:
- Backup destination is `/var/backups/...` (root-owned)
- Avoids permission edge cases
- systemd timers run cleanly as system services
- Standard practice for backup infrastructure

**2.2 Generate SSH Key for root@lab-backup**

```bash
# On lab-backup
sudo -i
ssh-keygen -t ed25519 -C "root@lab-backup"
# File: /root/.ssh/id_ed25519 (default)
# Passphrase: empty (required for non-interactive automation)

# Verify key creation
ls -l /root/.ssh/
# Expected: id_ed25519, id_ed25519.pub
```

**Security note**: Empty passphrase is acceptable for service keys in isolated lab environments. Production systems would use ssh-agent, key management systems, or hardware tokens.

**2.3 Install Public Key on lab-admin**

```bash
# From root@lab-backup
ssh-copy-id -i /root/.ssh/id_ed25519.pub yanglee@lab-admin
```

**Troubleshooting encountered**: SSH policy on lab-admin (`PasswordAuthentication no`, `Match all=yes`) prevented password-based key bootstrap.

**Resolution**:
1. Temporarily edited `/etc/ssh/sshd_config.d/90-hardened.conf` on lab-admin
2. Changed `Match all=yes` to `Match all=no`
3. Restarted SSH: `sudo systemctl restart sshd`
4. Ran `ssh-copy-id` successfully
5. Restored `Match all=yes`
6. Restarted SSH again

**Operational insight**: This is standard practice in hardened environments. SSH key bootstrapping requires a temporary exception to password policies, then immediate restoration. This should be documented as intentional operational procedure, not a workaround.

**2.4 Verify Passwordless SSH**

```bash
# From root@lab-backup
ssh yanglee@lab-admin "hostname && whoami"
# Expected output:
# lab-admin
# yanglee
```

**2.5 Test Remote Data Access**

```bash
# From root@lab-backup
ssh yanglee@lab-admin "ls -ld /research && ls /research | head"
# Expected: directory metadata and file listings
```

This confirms SSH key authentication works and remote user can access research data.

---

### Part 3: Snapshot-Style Backups with rsync

**Design: Snapshot Layout**

```
/var/backups/research/
├── current → 2026-01-06          # Symlink to latest snapshot
├── 2026-01-06/                   # Today's snapshot
├── 2026-01-05/                   # Yesterday's snapshot
├── 2026-01-04/
├── 2026-01-03/
└── ...
```

**Snapshot benefits**:
- Each date is a complete point-in-time view
- Unchanged files are hard-linked (same inode)
- Changed files are copied only once
- Space-efficient while providing recovery points
- Classic Unix backup design (used by Time Machine, rsnapshot, etc.)

**3.1 Initial Backup Script Attempt**

Created `/usr/local/bin/backup-research.sh`:

```bash
#!/bin/bash
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

# Run backup
if rsync $OPTS "$SRC" "$DEST"; then
    ln -sfn "$DEST" "$LINK"
    logger -t "$LOGTAG" "OK: Snapshot created at $DEST"
else
    logger -t "$LOGTAG" "FAIL: rsync error"
    exit 1
fi
```

**Set executable permissions**:
```bash
sudo chmod 0755 /usr/local/bin/backup-research.sh
```

**3.2 Initial Execution and Permission Challenge**

```bash
sudo /usr/local/bin/backup-research.sh
```

**Error encountered**:
```
rsync: [sender] opendir "/research/project1" failed: Permission denied (13)
IO error encountered -- skipping file deletion
rsync error: some files/attrs were not transferred (see previous errors) (code 23)
```

**Root cause analysis**:
- rsync connects as `yanglee@lab-admin` (SSH user)
- `/research/project1` has permissions `2770 root:project1`
- User `yanglee` is not in group `project1`
- Result: Cannot read project1 directory

**Design question**: Should backups bypass user-level restrictions?

**Answer**: YES. In research environments, backups must be complete. Incomplete backups are worse than no backups. The backup system must read all data regardless of project restrictions.

**3.3 Solution: Restricted sudo rsync**

**Step 1: Configure sudo on lab-admin**

```bash
# On lab-admin
sudo visudo -f /etc/sudoers.d/backup
```

Add this line:
```
yanglee ALL=(root) NOPASSWD:/usr/bin/rsync
```

**Security implications**:
- Grants `yanglee` permission to run `/usr/bin/rsync` as root
- Does NOT grant full sudo access
- NOPASSWD required for non-interactive automation
- Minimal privilege - only rsync, nothing else
- Auditable via sudo logs

**Why not other approaches**:

| Approach | Why NOT chosen |
|----------|----------------|
| Add yanglee to project1 | Breaks project isolation model |
| Relax directory permissions | Violates research access controls |
| ACLs everywhere | Overkill complexity for lab |
| Push backups from admin | We chose pull-based for security |

**Step 2: Modify backup script to use sudo rsync**

Updated rsync invocation:
```bash
rsync $OPTS --rsync-path="sudo rsync" "$SRC" "$DEST"
```

**What `--rsync-path="sudo rsync"` does**:
- Tells rsync to invoke `sudo rsync` on the remote (source) side
- SSH connects as yanglee, then executes rsync as root
- Preserves pull-based model while gaining read access

**3.4 Successful Backup Execution**

```bash
sudo /usr/local/bin/backup-research.sh
```

**Verification**:
```bash
ls -l /var/backups/research
# Expected: dated directory (e.g., 2026-01-06)

ls -l /var/backups/research/current
# Expected: symlink pointing to today's snapshot

ls /var/backups/research/current/project1
# Expected: project1 files successfully backed up
```

**3.5 Verify Hard-Linking (Snapshot Efficiency)**

Run backup script twice to create two snapshots:
```bash
sudo /usr/local/bin/backup-research.sh
# Wait or change date, run again
sudo /usr/local/bin/backup-research.sh
```

Check inode numbers:
```bash
ls -li /var/backups/research/*/alice-file
# Expected: identical inode numbers = hard link confirmed
```

**What this proves**:
- Unchanged files share the same disk blocks
- Space efficiency: only changed files consume additional space
- Each snapshot appears complete but shares data with previous snapshots

**3.6 Logging Verification**

```bash
journalctl -t research-backup --no-pager
```

Expected output:
```
Jan 06 10:30:15 lab-backup backup-research.sh[1234]: OK: Snapshot created at /var/backups/research/2026-01-06
```

This confirms journald integration for operational visibility.

---

### Part 4: Retention Policy

**Objective**: Prevent unlimited backup growth while maintaining useful recovery window.

**Policy chosen**: Keep last 7 daily snapshots, delete older ones.

**Why 7 days**:
- Balances storage capacity with recovery window
- Common retention for daily backups in research environments
- Simple, defensible, easy to explain

**4.1 Add Retention Logic to Script**

Final version of `/usr/local/bin/backup-research.sh`:

```bash
#!/bin/bash
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

# Run backup
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
```

**Retention logic breakdown**:
- `ls -1d 20*` - list only snapshot directories (named YYYY-MM-DD)
- `sort` - chronological order
- `head -n -7` - output all except newest 7
- `rm -rf` - delete old snapshots
- `logger` - log each removal

**Safety features**:
- Directory naming is controlled (YYYY-MM-DD format)
- `current` symlink is not matched by `20*` pattern
- Removal only happens after successful backup
- Each removal is logged for auditability

**4.2 Test Retention**

Create simulated old snapshots:
```bash
sudo mkdir /var/backups/research/2025-12-{01..05}
```

Run backup:
```bash
sudo /usr/local/bin/backup-research.sh
```

Verify retention:
```bash
ls /var/backups/research
# Expected: only 7 most recent directories remain
```

Check logs:
```bash
journalctl -t research-backup --no-pager
# Expected: log entries showing old snapshot removals
```

---

### Part 5: systemd Automation

**Objective**: Run backups automatically, reliably, and observably without manual intervention.

**Design choice: systemd over cron**

Why systemd timers are superior:
- **Integrated logging** - journalctl shows all execution history
- **Dependency awareness** - can wait for network-online.target
- **Persistent execution** - runs missed backups after reboot
- **Better failure visibility** - systemctl status shows service state
- **Industry standard** - modern Linux systems use systemd

**5.1 Create systemd Service Unit**

Created `/etc/systemd/system/research-backup.service`:

```ini
[Unit]
Description=Snapshot backup of /research from lab-admin
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-research.sh

[Install]
WantedBy=multi-user.target
```

**Unit file breakdown**:
- `Wants=network-online.target` - prefer network is ready (soft dependency)
- `After=network-online.target` - wait for network before starting
- `Type=oneshot` - run once and exit (not a long-running daemon)
- `ExecStart=...` - command to execute
- Runs as root by default (correct for backup operations)

**5.2 Create systemd Timer Unit**

Created `/etc/systemd/system/research-backup.timer`:

```ini
[Unit]
Description=Daily snapshot backup timer for research data

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

**Timer configuration**:
- `OnCalendar=daily` - execute once per day (midnight)
- `Persistent=true` - critically important for reliability

**What `Persistent=true` does**:
- If system was off when backup was scheduled, run it immediately after boot
- Prevents missed backups due to downtime
- Essential for production backup reliability

**5.3 Enable and Start Timer**

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now research-backup.timer
```

**What this does**:
- `daemon-reload` - reload systemd configuration
- `enable` - start timer automatically on boot
- `--now` - start timer immediately (don't wait for reboot)

**5.4 Verify Timer is Active**

```bash
systemctl list-timers | grep research
```

Expected output:
```
NEXT                         LEFT       LAST PASSED UNIT                      ACTIVATES
Tue 2026-01-07 00:00:00 PST  13h left   n/a  n/a    research-backup.timer     research-backup.service
```

This shows:
- Timer is active
- Next scheduled execution time
- Service it will trigger

**5.5 Test Service Manually**

```bash
sudo systemctl start research-backup.service
```

**Check execution logs**:
```bash
# Service-level logs (systemd execution)
journalctl -u research-backup.service --no-pager

# Application-level logs (script output)
journalctl -t research-backup --no-pager
```

Expected log output:
```
Jan 06 11:45:22 lab-backup systemd[1]: Starting Snapshot backup of /research from lab-admin...
Jan 06 11:45:28 lab-backup backup-research.sh[5678]: OK: Snapshot created at /var/backups/research/2026-01-06
Jan 06 11:45:28 lab-backup systemd[1]: research-backup.service: Succeeded.
```

**5.6 Verify Snapshot Integrity**

```bash
ls -l /var/backups/research
# Expected: dated snapshot directories

ls -l /var/backups/research/current
# Expected: symlink pointing to latest snapshot

# Optional: verify hard-linking
ls -li /var/backups/research/*/alice-file
# Expected: identical inode numbers across snapshots
```

---

## Key Technical Decisions

### Pull-Based vs Push-Based Architecture

**Pull-based (chosen)**:
- Backup server initiates connections
- Backup server controls schedule
- Source server cannot overwrite backups
- Industry best practice

**Push-based (NOT chosen)**:
- Source server pushes to backup
- Compromised source could destroy backups
- Backup server is passive recipient
- Less secure model

**Interview-level insight**: "I implemented pull-based backups where the backup server controls orchestration and the source server cannot overwrite historical snapshots. This provides a security boundary against compromised admin nodes."

---

### sudo rsync for Restricted Directories

**Problem**: User-level SSH accounts cannot read restricted project directories.

**Solution**: Tightly scoped sudo rule allowing only `/usr/bin/rsync` execution as root.

**Why this is correct**:
- Preserves least-privilege principle (only rsync, nothing else)
- Maintains project isolation on source server
- Enables complete backups without permission relaxation
- Standard practice in production environments
- Auditable via sudo logs

**Alternative approaches rejected**:
- Adding backup user to all project groups → violates isolation
- Relaxing directory permissions → security risk
- Running SSH as root directly → excessive privilege

---

### Snapshot Layout with Hard-Linking

**Technique**: `rsync --link-dest=<previous_snapshot>`

**How it works**:
1. rsync compares new files against previous snapshot
2. Unchanged files: create hard link (same inode, no additional space)
3. Changed files: copy new version (additional space consumed)
4. Result: each snapshot appears complete, but shares unchanged data

**Benefits**:
- Space-efficient (unchanged files don't consume additional storage)
- Point-in-time recovery (any snapshot can be browsed/restored independently)
- Simple restoration (just copy from snapshot directory)
- No special tools required (standard filesystem operations)

**Real-world analogs**:
- macOS Time Machine uses same technique
- rsnapshot backup tool
- ZFS/Btrfs snapshots (different implementation, same concept)

---

### systemd vs cron

**Why systemd timers are superior**:

| Feature | systemd | cron |
|---------|---------|------|
| Logging | Integrated journald | Separate logs or email |
| Dependencies | Can wait for network, filesystem | Manual scripting required |
| Missed runs | Persistent=true catches up | Lost forever |
| Failure visibility | systemctl status shows state | Must check logs manually |
| Boot integration | Proper dependency ordering | Fixed delay or @reboot |
| Standardization | Modern Linux standard | Legacy Unix tool |

**When to use cron**: Simple scheduled tasks on older systems without systemd.

**When to use systemd**: All new Linux automation (industry direction).

---

## Troubleshooting Notes

### Issue 1: SSH Key Bootstrap with Hardened SSH Policy

**Problem**: `ssh-copy-id` failed because lab-admin SSH configuration disabled password authentication:
```
/etc/ssh/sshd_config.d/90-hardened.conf:
PasswordAuthentication no
Match all=yes
```

**Error**:
```
Permission denied (publickey)
```

**Root Cause**: `ssh-copy-id` requires password authentication to bootstrap the initial key. Catch-22 situation: need SSH key to connect, but can't install key without password auth.

**Resolution**:
1. Temporarily edited `/etc/ssh/sshd_config.d/90-hardened.conf` on lab-admin
2. Changed `Match all=yes` to `Match all=no` (disables Match block)
3. Restarted SSH: `sudo systemctl restart sshd`
4. Successfully ran `ssh-copy-id -i /root/.ssh/id_ed25519.pub yanglee@lab-admin`
5. Restored `Match all=yes` in config file
6. Restarted SSH again to re-enable hardening

**Operational insight**: This is not a workaround - it's standard operating procedure in hardened environments. SSH key bootstrapping requires a temporary exception to password policies. The key points are:
- Exception was minimal and time-limited
- Policy was immediately restored
- Procedure was documented
- Alternative would be manual key installation via console access

**Best practice**: Document this as intentional operational procedure:
> "SSH key bootstrapping required temporary relaxation of password authentication policy. Policy was restored immediately after key installation. This is standard practice in hardened environments where initial key deployment requires a controlled exception window."

---

### Issue 2: Permission Denied on project1 Directory

**Problem**: Initial backup failed with:
```
rsync: [sender] opendir "/research/project1" failed: Permission denied (13)
IO error encountered -- skipping file deletion
rsync error: some files/attrs were not transferred (see previous errors) (code 23)
```

**Root Cause Analysis**:
- rsync connects via SSH as `yanglee@lab-admin`
- `/research/project1` permissions: `2770 root:project1`
- User `yanglee` is not in group `project1`
- Standard Unix permissions prevent access

**Why this happened**:
- Project directories were intentionally restricted (Day 2 setup)
- Backup user was not added to project groups (correct isolation)
- Result: incomplete backups

**Design decision**: Should backups bypass user restrictions?

**Answer**: YES - backups must be complete. Incomplete backups are worse than no backups. The backup system is a privileged infrastructure component and must have read access to all data.

**Solution**: Restricted sudo rule on lab-admin

Created `/etc/sudoers.d/backup`:
```
yanglee ALL=(root) NOPASSWD:/usr/bin/rsync
```

Modified backup script to use sudo on remote side:
```bash
rsync $OPTS --rsync-path="sudo rsync" "$SRC" "$DEST"
```

**What this accomplishes**:
- SSH still connects as `yanglee` (preserves audit trail)
- rsync executes as root on source (can read restricted directories)
- Minimal privilege (only rsync, not full sudo)
- Non-interactive (NOPASSWD required for automation)

**Security review**:
- ✅ Least privilege - only grants access to rsync binary
- ✅ No interactive commands - prevents privilege escalation
- ✅ Auditable - sudo logs all invocations
- ✅ Targeted - only affects backup operations

**Learning**: This scenario demonstrates the difference between user permissions and operational requirements. Backup systems are infrastructure, not user accounts, and require privileged access to fulfill their function.

---

### Issue 3: Backup Directory Permissions (0750 vs 0700)

**Context**: Created `/var/backups/research` with permissions `0750`:
```bash
sudo chmod 0750 /var/backups/research
```

**What 0750 means**:
- Owner (root): read, write, execute (full access)
- Group (root): read, execute (can browse)
- Others: no access

**Expected behavior**: Regular user `yanglee` cannot access directory:
```bash
yanglee@lab-backup:/var/backups$ cd research
-bash: cd: research: Permission denied
```

**Why this is CORRECT, not an error**:
- Backups contain all research data, including restricted projects
- Regular users should not be able to browse backup directories
- This is intentional security design
- Only root can access backups

**How to access when needed**:
```bash
# As root
sudo ls /var/backups/research
sudo ls /var/backups/research/current

# Or switch to root shell
sudo -i
cd /var/backups/research
ls
```

**Could use 0700 instead**:
- Owner (root): full access
- Group: no access
- Others: no access

Both 0750 and 0700 prevent regular user access. 0750 chosen to allow potential group-based access in future (e.g., dedicated backup-operators group).

**Learning**: Permission denied on backup directories is a feature, not a bug. Backups are privileged data and should be protected accordingly.

---

## Files Created

All files created on **lab-backup** node:

```
/usr/local/bin/backup-research.sh          # Snapshot backup script
/etc/systemd/system/research-backup.service # systemd service unit
/etc/systemd/system/research-backup.timer   # systemd timer unit
/var/backups/research/                      # Backup storage directory
  ├── current -> 2026-01-06                 # Symlink to latest snapshot
  ├── 2026-01-06/                           # Snapshot directories
  ├── 2026-01-05/
  └── ...
```

All files created/modified on **lab-admin** node:

```
/etc/sudoers.d/backup                       # Restricted sudo rule for rsync
~yanglee/.ssh/authorized_keys               # Contains root@lab-backup public key
```

---

## Commands Reference

### Backup Script Execution

```bash
# Manual backup execution (testing)
sudo /usr/local/bin/backup-research.sh

# Verify backup created
ls -l /var/backups/research
ls -l /var/backups/research/current

# Check hard-linking (space efficiency)
ls -li /var/backups/research/*/alice-file
```

### systemd Service Management

```bash
# Reload systemd after unit file changes
sudo systemctl daemon-reload

# Enable timer (start on boot)
sudo systemctl enable research-backup.timer

# Start timer immediately
sudo systemctl start research-backup.timer

# Enable and start in one command
sudo systemctl enable --now research-backup.timer

# Check timer status
systemctl list-timers | grep research
systemctl status research-backup.timer

# Manually trigger backup (testing)
sudo systemctl start research-backup.service

# Check service status
systemctl status research-backup.service
```

### Logging and Monitoring

```bash
# View backup script logs (application level)
journalctl -t research-backup --no-pager
journalctl -t research-backup -f              # Follow mode

# View service logs (systemd level)
journalctl -u research-backup.service --no-pager
journalctl -u research-backup.service -n 20   # Last 20 lines

# View timer logs
journalctl -u research-backup.timer --no-pager

# Check recent backup executions
journalctl -t research-backup --since today
journalctl -t research-backup --since "1 hour ago"
```

### SSH Key Management

```bash
# Generate SSH key (on lab-backup)
sudo -i
ssh-keygen -t ed25519 -C "root@lab-backup"

# Install public key (from lab-backup)
ssh-copy-id -i /root/.ssh/id_ed25519.pub yanglee@lab-admin

# Test SSH connectivity
ssh yanglee@lab-admin "hostname"
ssh yanglee@lab-admin "ls /research"
```

### Backup Verification

```bash
# List all snapshots
ls -lh /var/backups/research

# Browse specific snapshot
ls -lh /var/backups/research/2026-01-06

# Compare snapshots (file-level)
diff -r /var/backups/research/2026-01-05 /var/backups/research/2026-01-06

# Check disk usage (with hard links accounted)
du -sh /var/backups/research
du -sh /var/backups/research/*

# Verify hard-linking (inode comparison)
ls -li /var/backups/research/*/alice-file
```

### Restoration Examples

```bash
# Restore single file
sudo cp /var/backups/research/2026-01-05/alice-file /research/

# Restore entire directory
sudo rsync -a /var/backups/research/2026-01-05/ /research/

# Preview what would be restored (dry-run)
sudo rsync -a --dry-run /var/backups/research/2026-01-05/ /research/
```

---

## Key Learnings

### 1. Pull-Based Architecture is a Security Boundary

Pull-based backups create a trust boundary where the backup server is authoritative and source servers cannot corrupt backup history. This is critical for ransomware protection and operational safety.

**Interview insight**: "I implemented pull-based backups where the backup server initiates all transfers and controls retention. This prevents compromised source systems from overwriting historical snapshots, providing a security boundary for data recovery."

---

### 2. Backup Systems Require Privileged Access

Backups are infrastructure, not user operations. They must bypass user-level restrictions to ensure completeness. The solution is tightly scoped privilege escalation (sudo for specific binaries only), not permission relaxation.

**Key principle**: Incomplete backups are worse than no backups. The backup system must have read access to all protected data.

---

### 3. SSH Key Bootstrap Creates Operational Edge Cases

Hardened SSH configurations (password auth disabled) create a catch-22 for initial key deployment. The correct solution is a controlled exception window, immediately restored after key installation. This should be documented as intentional operational procedure, not a workaround.

---

### 4. Snapshot Backups with Hard-Linking Balance Space and History

Using `rsync --link-dest` provides point-in-time recovery without duplicating unchanged files. This technique:
- Mimics ZFS/Btrfs snapshots using standard tools
- Requires no special filesystem features
- Enables simple restoration (just copy from snapshot directory)
- Is space-efficient and production-proven

---

### 5. systemd Timers Provide Superior Operational Visibility

Compared to cron, systemd timers offer:
- Integrated logging via journald
- Network dependency handling
- Persistent execution (catch up after downtime)
- Clear failure visibility via systemctl

For modern Linux automation, systemd is the industry standard.

---

### 6. Retention Policies Must Be Automated

Manual cleanup leads to forgotten maintenance and unbounded storage growth. Automated retention with logging provides:
- Predictable storage consumption
- Auditable cleanup operations
- Reduced operational burden

---

### 7. Backup Directories Should Be Privileged Storage

Backups contain copies of all data, including restricted projects. They should be stored with root-only permissions (0750 or 0700) to prevent unauthorized access via backup browsing.

---

### 8. Role Separation Matters in Multi-Node Architectures

Each node has a distinct responsibility:
- lab-admin: authoritative data source
- lab-compute: data consumer (never backs up shared storage)
- lab-backup: backup operations (never mounts live storage)

This separation prevents:
- Circular dependencies
- Backup corruption from mount conflicts
- Confusion about authoritative sources

---

### 9. Scripts Must Use Strict Mode for Reliability

`set -euo pipefail` is a hallmark of professional shell scripting:
- `-e`: Exit on error (fail-fast)
- `-u`: Error on undefined variables (prevents `rm -rf /$UNDEFINED_VAR`)
- `-o pipefail`: Pipeline failures propagate (catch errors in pipes)

This prevents silent failures and data loss in automation scripts.

---

### 10. Documentation of Operational Challenges Shows Maturity

Real systems encounter edge cases. Documenting challenges like SSH key bootstrap or permission handling demonstrates:
- Operational awareness
- Problem-solving capability
- Understanding of security vs. usability tradeoffs
- Professional maturity

**Interview insight**: Being able to explain *why* you made specific decisions (pull vs. push, sudo rsync, systemd vs. cron) demonstrates systems thinking, not just execution ability.

---

## Portfolio Connections

### How This Demonstrates Job-Required Skills

**Storage & Backup Administration**:
- Designed and implemented off-host backup infrastructure
- Chose appropriate tools (rsync, hard-linking) for snapshot backups
- Applied retention policies to balance recovery window and storage capacity
- Documented restoration procedures

**Operational Reliability**:
- Implemented pull-based architecture for backup integrity
- Used systemd for deterministic, observable automation
- Integrated journald logging for operational visibility
- Tested failure scenarios (permission denied, SSH issues)

**Security-Aware Design**:
- Established trust boundaries (backup server controls retention)
- Used tightly scoped sudo rules (minimal privilege)
- Protected backup storage with restrictive permissions
- Documented security tradeoffs in design decisions

**Linux System Administration**:
- Managed SSH key authentication for automation
- Created and managed systemd service and timer units
- Understood filesystem permissions and their operational impact
- Handled real operational challenges (key bootstrap, permission conflicts)

**Research Data Protection**:
- Implemented backup strategy appropriate for sensitive research data
- Ensured backups can read all project directories despite access restrictions
- Provided point-in-time recovery capability
- Balanced security (restricted access) with operational needs (complete backups)

---

### Resume Bullet - Off-Host Backup Implementation

**Recommended phrasing**:

> "Designed and implemented pull-based off-host backup system using rsync snapshot-style backups with hard-linked retention (7-day policy). Established secure SSH trust model with restricted sudo access for privileged data access. Automated backup orchestration via systemd timers with integrated journald logging for operational visibility. Implemented 3-node architecture (source/consumer/backup) with clear separation of concerns and security boundaries."

**Evidence**:
- Pull-based backup architecture (security boundary)
- rsync --link-dest for space-efficient snapshots
- Automated retention policy (7 snapshots)
- systemd service + timer automation
- Restricted sudo rule for privileged access
- Documented troubleshooting (SSH bootstrap, permission handling)

---

### Interview Talking Points

**Q: "Tell me about a backup system you've implemented."**

> "In my Linux admin lab, I implemented a 3-node backup architecture with dedicated backup infrastructure. I chose a pull-based model where the backup server controls scheduling and retention, which creates a security boundary - even if the admin node is compromised, attackers cannot overwrite historical backups.
>
> I used rsync with --link-dest for snapshot-style backups, which provides point-in-time recovery without duplicating unchanged files. This is the same technique used by Time Machine and enterprise backup tools.
>
> An interesting challenge was handling restricted project directories. The backup user didn't have access to all projects, which would result in incomplete backups. I solved this with a tightly scoped sudo rule - the backup user can only run rsync as root, nothing else. This preserves project isolation on the source server while ensuring complete backups.
>
> I automated the backups with systemd timers rather than cron, which gives better operational visibility through journald logging and handles network dependencies properly."

**Q: "How do you ensure backups are actually working?"**

> "Backups aren't real until you've tested restoration. In my lab, I simulated accidental deletion and performed file restoration from snapshots. I also verify hard-linking is working correctly by checking inode numbers - if unchanged files have the same inode across snapshots, I know the space efficiency is working as designed.
>
> For ongoing monitoring, all backup executions log to journald with a dedicated tag, so I can easily query recent backup status. The systemd service reports success/failure, and I can see that in systemctl status."

**Q: "Why pull-based instead of push-based backups?"**

> "Pull-based gives the backup server control over scheduling and retention. If the admin node gets compromised, attackers can't push malicious data to overwrite backups. The backup server pulls data on its own schedule and manages its own retention.
>
> It also simplifies the trust model - the admin server doesn't need credentials for the backup server, only the backup server needs credentials for the admin server. And those credentials are read-only via SSH keys and scoped sudo."

---

## References

### Backup Tools & Techniques

- **rsync**: https://man7.org/linux/man-pages/man1/rsync.1.html
  Fast, versatile file copying tool

- **rsync --link-dest**: https://download.samba.org/pub/rsync/rsync.1#opt--link-dest
  Hardlink to files in DIR when unchanged (snapshot technique)

- **rsync --rsync-path**: https://download.samba.org/pub/rsync/rsync.1#opt--rsync-path
  Specify the rsync to run on remote machine (enables sudo usage)

### systemd

- **systemd.service**: https://www.freedesktop.org/software/systemd/man/systemd.service.html
  Service unit configuration

- **systemd.timer**: https://www.freedesktop.org/software/systemd/man/systemd.timer.html
  Timer unit configuration for scheduled tasks

- **systemd.time**: https://www.freedesktop.org/software/systemd/man/systemd.time.html
  Time and date specifications (OnCalendar format)

### SSH

- **ssh-keygen**: https://man7.org/linux/man-pages/man1/ssh-keygen.1.html
  Authentication key generation and management

- **ssh-copy-id**: https://man.openbsd.org/ssh-copy-id.1
  Install SSH identity on remote machine

- **sshd_config**: https://man7.org/linux/man-pages/man5/sshd_config.5.html
  OpenSSH daemon configuration

### Security

- **sudo**: https://www.sudo.ws/man/1.8.27/sudo.man.html
  Execute command as another user

- **sudoers**: https://www.sudo.ws/man/1.8.27/sudoers.man.html
  Default sudo security policy plugin

### Logging

- **journalctl**: https://man7.org/linux/man-pages/man1/journalctl.1.html
  Query systemd journal

- **logger**: https://man7.org/linux/man-pages/man1/logger.1.html
  Enter messages into system log

### Shell Scripting

- **Bash set builtin**: https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
  Set shell options (explains -euo pipefail)

---

**Status**: ✅ Day 7 Complete (2026-01-06)

**Next**: Day 8 - Advanced topics (monitoring, Ansible backup automation, or portfolio documentation)
