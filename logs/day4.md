# Day 4 — Shared Storage with NFS

**Date:** 2026-01-03
**Planned Outcomes:** Centralized shared storage using NFS for research collaboration
**Status:** ✅ Complete

## Objective

Implement centralized shared storage using NFS to simulate a real academic research computing environment where:

- Data lives on a single authoritative node (`lab-admin`)
- Compute nodes (`lab-compute`) consume shared data transparently
- Linux permissions and group-based collaboration are enforced consistently
- Storage mounts are persistent, resilient, and non-blocking

This reflects standard practice in university and research labs.

---

## Architecture

**Before Day 4:**
- `/research` existed independently on each machine ❌
- Data was duplicated ❌
- Not representative of real research infrastructure

**After Day 4:**
```
lab-admin (control + storage authority)
└── /research
    ├── project1/
    └── (future projects)

lab-compute (compute / user access)
└── /research  → NFS mount from lab-admin
```

**Design Principles:**
- One source of truth for data
- Permissions enforced server-side (lab-admin)
- No data duplication on compute nodes
- Clear separation of control-plane vs compute-plane

---

## Preconditions

From Days 1–3, the following were already in place:

**Identical users and groups on both nodes:**
- Users: `alice`, `bob`, `carol`
- Groups: `researchers`, `project1`

**Verified permission model:**
- `/research` → group `researchers`, setgid, writable by group
- `/research/project1` → group `project1`, restricted access (770)

**Network connectivity:**
- `lab-admin` ↔ `lab-compute` reachable via SSH/ping
- SSH access to `lab-admin` restricted to admins only

---

## Part 1 — Permission Model Validation

### Verified Directory Permissions

On `lab-admin`:
```bash
ls -ld /research /research/project1
```

**Expected state:**
```
drwxrwsr-x root researchers /research
drwxrws--- root project1    /research/project1
```

**Interpretation:**
- All users can traverse `/research`
- Only `researchers` group members can write to `/research`
- Only `project1` members can access project data
- setgid bit ensures new files inherit correct group ownership

This enforces visibility without modification and strict project isolation.

---

## Part 2 — NFS Server Configuration (lab-admin)

### Install NFS Server

```bash
sudo apt update
sudo apt install -y nfs-kernel-server
```

### Configure Exports

Created `/etc/exports` entry:
```
/research lab-compute(rw,sync,no_subtree_check)
```

**Options explained:**
- `rw` — Allow read/write requests (filesystem permissions still apply)
- `sync` — Acknowledge writes only after disk commit (data integrity)
- `no_subtree_check` — Avoid unnecessary path validation for stable directories

### Apply and Verify Exports

```bash
sudo exportfs -ra       # Re-export all filesystems
sudo exportfs -v        # Verify exports
```

**Expected output:**
```
/research lab-compute(rw,sync,wdelay,hide,no_subtree_check,...)
```

### Verify NFS Service Availability

```bash
rpcinfo -p | grep nfs
```

This confirms NFS RPC services are registered and listening.

---

## Part 3 — NFS Client Setup & Temporary Mount (lab-compute)

### Install NFS Client Utilities

```bash
sudo apt install -y nfs-common
```

### Mount Shared Storage (Temporary Test)

```bash
sudo mount lab-admin:/research /research
```

### Verify Mount

```bash
mount | grep research
df -h | grep research
```

**Expected output:**
```
lab-admin:/research on /research type nfs4 (rw,relatime,...)
```

This confirms `/research` is now a remote filesystem served by `lab-admin`.

---

## Part 4 — Permission Verification over NFS

All tests performed on `lab-compute` to verify server-side permission enforcement.

### Test 1: Non-Research User

```bash
sudo -u nobody ls /research          # Should succeed (read access)
sudo -u nobody touch /research/test  # Should fail (write denied)
```

**Result:**
- Directory listing allowed ✅
- Write denied ✅

### Test 2: Researcher (Not in project1)

```bash
sudo -u carol touch /research/carol_test       # Should succeed
sudo -u carol ls /research/project1            # Should fail
```

**Result:**
- Write to `/research` succeeds ✅
- Access to `project1` denied (Permission denied) ✅

### Test 3: Project Member

```bash
sudo -u alice touch /research/project1/alice_file
sudo -u alice ls -l /research/project1
```

**Result:**
- File creation succeeds ✅
- Group ownership = `project1` ✅
- setgid inheritance preserved ✅

**Key Validation:**

This confirms server-side permission enforcement works correctly across NFS. Permissions configured on `lab-admin` are transparently enforced on `lab-compute` without additional configuration.

---

## Part 5 — Persistent & Resilient Mount Configuration

### /etc/fstab Entry (lab-compute)

Added to `/etc/fstab`:
```
lab-admin:/research  /research  nfs  defaults,_netdev,x-systemd.automount  0  0
```

**Rationale:**
- `_netdev` — Mount only after networking is available
- `x-systemd.automount` — Mount on first access, avoid boot blocking
- `0 0` — Disable dump and fsck (correct for network filesystems)

### Why These Options Matter

**Without `_netdev`:**
- System might try to mount before network is ready
- Boot would fail or hang

**Without `x-systemd.automount`:**
- Mount happens at boot time
- If NFS server is unreachable, boot blocks indefinitely

**With automount:**
- Mount point exists immediately
- Actual NFS mount happens on first access
- Non-blocking boot process

### Validate Configuration

```bash
sudo mount -a    # Test fstab without rebooting
```

**Trigger automount:**
```bash
ls /research
mount | grep research
```

**Expected behavior:**
- First access triggers the mount
- Subsequent access is immediate
- System boots successfully even if NFS server is temporarily down

---

## Security Validation

### Cross-Node Access Control

From `lab-compute` as researcher:
```bash
ssh alice@lab-admin
```

**Expected result:**
```
Permission denied (publickey).
```

**Why this matters:**
- Prevents lateral movement from compute to control-plane node
- Researchers can access shared data via NFS
- Researchers cannot access administrative systems
- Enforces security boundaries established in Day 3

---

## Outcome

By the end of Day 4:

✅ **Shared research storage is centralized on lab-admin**
- Single source of truth for data
- No duplication or synchronization issues

✅ **Compute nodes access data transparently via NFS**
- Users see `/research` as if it were local
- No manual data movement required

✅ **Permissions and group collaboration behave consistently**
- Server-side enforcement
- setgid inheritance works across NFS
- Project isolation maintained

✅ **Mounts are persistent, resilient, and non-blocking**
- Survives reboots
- Doesn't block boot if NFS server is down
- Automounts on first access

✅ **Environment mirrors real academic research infrastructure**
- Standard NFS-based shared storage
- UID/GID-based permissions
- Control-plane vs compute-plane separation

---

## Key Learnings

1. **NFS is transparent:** Once mounted, users can't tell the difference between local and remote filesystems. Permissions "just work" because they're enforced on the server.

2. **User/group consistency is critical:** NFS relies on matching UIDs and GIDs between server and client. Our Day 2 work ensuring identical users/groups was prerequisite to this working correctly.

3. **Mount options matter:** `_netdev` and `x-systemd.automount` are the difference between a fragile system and a production-ready one.

4. **Security boundaries are layered:** SSH restrictions (Day 3) + NFS exports (Day 4) = defense in depth. Data access doesn't imply admin access.

5. **Test as actual users:** Using `sudo -u` to test as different users reveals how permissions actually work, not how you think they work.

6. **Separation of concerns:** Storage management (lab-admin) vs compute usage (lab-compute) reflects real-world research IT operations.

---

## Technical Commands Reference

```bash
# NFS Server (lab-admin)
sudo apt install nfs-kernel-server
sudo exportfs -ra          # Re-export all
sudo exportfs -v           # Verify exports
rpcinfo -p | grep nfs      # Check NFS services

# NFS Client (lab-compute)
sudo apt install nfs-common
sudo mount <server>:<path> <mountpoint>
mount | grep <mountpoint>  # Verify mount
df -h | grep <mountpoint>  # Check disk usage

# Permission testing
sudo -u <username> <command>

# Mount management
sudo mount -a              # Test fstab entries
sudo umount <mountpoint>   # Unmount
```

---

## References — Day 4

### NFS

- **exports**: [https://man7.org/linux/man-pages/man5/exports.5.html](https://man7.org/linux/man-pages/man5/exports.5.html)
  NFS server export table

- **nfs**: [https://man7.org/linux/man-pages/man5/nfs.5.html](https://man7.org/linux/man-pages/man5/nfs.5.html)
  NFS filesystem options and behavior

- **exportfs**: [https://man7.org/linux/man-pages/man8/exportfs.8.html](https://man7.org/linux/man-pages/man8/exportfs.8.html)
  Maintain table of exported NFS filesystems

### Mounting & Filesystem Management

- **mount**: [https://man7.org/linux/man-pages/man8/mount.8.html](https://man7.org/linux/man-pages/man8/mount.8.html)
  Mount a filesystem

- **fstab**: [https://man7.org/linux/man-pages/man5/fstab.5.html](https://man7.org/linux/man-pages/man5/fstab.5.html)
  Static filesystem mount configuration

- **systemd.mount**: [https://www.freedesktop.org/software/systemd/man/systemd.mount.html](https://www.freedesktop.org/software/systemd/man/systemd.mount.html)
  systemd mount unit configuration

### Network Services

- **rpcinfo**: [https://man7.org/linux/man-pages/man8/rpcinfo.8.html](https://man7.org/linux/man-pages/man8/rpcinfo.8.html)
  Report RPC information

### Ubuntu

- **Ubuntu NFS Guide**: [https://ubuntu.com/server/docs/service-nfs](https://ubuntu.com/server/docs/service-nfs)
  Official Ubuntu Server NFS documentation
