# Operations

This document describes **day-to-day operational workflows** for the Linux Research Computing Lab. The focus is on how an administrator would actually manage, verify, and troubleshoot the environment in practice.

---

## User & Group Management

### User Model

Users represent researchers working across shared infrastructure.

* Users are created locally on each node (prior to centralized auth)
* Group membership defines access, not individual ownership

Key groups:

* `researchers` – general research access
* `project1` – restricted project collaboration

### Common Commands

Create a user:

```bash
sudo adduser alice
```

Add user to a group:

```bash
sudo usermod -aG researchers alice
sudo usermod -aG project1 alice
```

Verify user and group membership:

```bash
getent passwd alice
getent group researchers
groups alice
```

---

## Filesystem & Permissions

### Research Storage Layout

Authoritative storage exists on **lab-admin**:

```text
/research
├── alice-file
├── bob-file
└── project1/
```

Permissions:

* `/research` → `2775 root:researchers`
* `/research/project1` → `2770 root:project1`

This ensures:

* Researchers can collaborate at the top level
* Only project members can access restricted directories
* New files inherit correct group ownership via setgid

### Verification Commands

```bash
ls -ld /research /research/project1
```

Test access as different users:

```bash
sudo -u carol touch /research/test
sudo -u carol ls /research/project1
sudo -u alice touch /research/project1/alice_file
```

---

## Shared Storage (NFS)

### Mount Model

* `/research` is exported from **lab-admin**
* Mounted on **lab-compute** via NFSv4
* Automounted using systemd

Mount verification:

```bash
mount | grep research
df -h | grep research
```

The compute node never owns data — it consumes it.

---

## SSH Access & Security

### Authentication Model

* SSH key-based authentication only
* Password authentication disabled
* Per-user access enforced

Key files:

* `/etc/ssh/sshd_config`
* `/etc/ssh/sshd_config.d/*.conf`

Verification:

```bash
sshd -T | grep -i passwordauthentication
```

### Operational Note

During initial key bootstrapping, password authentication was temporarily enabled and then disabled again. This workflow was documented and reversed immediately.

---

## Backup Operations

### Backup Model

* Pull-based backups from lab-admin to lab-backup
* Snapshot-style using `rsync --link-dest`
* Backups run as root
* Backup storage is root-only

Manual backup run:

```bash
sudo /usr/local/bin/backup-research.sh
```

### Backup Verification

List snapshots:

```bash
sudo ls /var/backups/research
```

Check latest snapshot:

```bash
sudo ls /var/backups/research/current
```

View logs:

```bash
journalctl -t research-backup
```

---

## Restore Test (Validation)

To validate backups without impacting live data:

```bash
sudo mkdir /tmp/restore-test
sudo cp /var/backups/research/current/alice-file /tmp/restore-test/
ls -l /tmp/restore-test
sudo rm -rf /tmp/restore-test
```

This confirms:

* Data integrity
* Correct ownership
* Snapshot usability

---

## Monitoring & Health Checks

### Research Storage Health

A systemd service runs a lightweight health check on compute nodes:

```bash
journalctl -t research-check
```

This ensures required storage is present before workloads run.

---

## Common Troubleshooting Commands

```bash
systemctl status nfs-server
systemctl status research-health.service
journalctl -xe
mount | grep nfs
```

---

## Operational Philosophy

* Prefer explicit checks over assumptions
* Fail fast when required resources are unavailable
* Keep backup and compute concerns separate
* Document deviations and edge cases

This reflects real-world research computing operations.
