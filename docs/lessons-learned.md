# Lessons Learned

This document captures the **practical lessons, mistakes, edge cases, and decisions** encountered while building and operating the Linux Research Computing Lab.

These lessons are intentionally documented because they reflect *real operational work*, not idealized configurations.

---

## 1. SSH Hardening Requires Bootstrapping

### What Happened

SSH was hardened early to enforce:

* Key-based authentication only
* Password authentication disabled

When introducing a new node (lab-backup), SSH key exchange initially failed because **password authentication was already disabled**.

### Resolution

* Temporarily relaxed the SSH policy
* Installed the required SSH keys
* Immediately re-enabled strict key-only access

### Lesson

> Security hardening often requires a controlled bootstrap window.

This is normal in production environments and must be:

* documented
* time-limited
* reversible

---

## 2. Permissions Worked — Until Backups Needed Them Not To

### What Happened

Project directories were intentionally restricted:

* `/research/project1` → accessible only to `project1` members

When implementing backups, rsync initially failed with:

```text
Permission denied (13)
```

### Resolution

* Kept user permissions unchanged
* Configured rsync to run as root on the source host via:

```bash
--rsync-path="sudo rsync"
```

* Added a **tightly scoped sudo rule** allowing only rsync

### Lesson

> Backups must bypass user permissions *without weakening them*.

This reinforced the importance of:

* least privilege
* explicit sudo rules
* separating access control from data protection

---

## 3. systemd Automount Affects Testing

### What Happened

The `/research` filesystem was automounted using systemd.

During health-check testing:

* Manual `umount` appeared to succeed
* The mount immediately reappeared when accessed

This caused health checks to appear "always successful".

### Resolution

* Identified systemd automount behavior
* Temporarily masked the automount unit during testing
* Restored automount after validation

### Lesson

> Automation layers can obscure failure modes during testing.

Understanding systemd behavior was essential to accurate validation.

---

## 4. Ansible Should Encode Known-Good State

### What Happened

Ansible was introduced only after:

* manual setup
* debugging
* repeated verification

Early playbooks failed due to:

* missing groups
* incorrect task ordering
* over-broad host targeting

### Resolution

* Reduced scope of playbooks
* Added prerequisite tasks (e.g., group creation)
* Used handlers for service reloads

### Lesson

> Automation should follow understanding, not replace it.

Idempotent automation is most effective when it encodes a *proven configuration*.

---

## 5. Root-Only Backup Access Is Correct (Even If Inconvenient)

### What Happened

Attempting to inspect backup directories as a regular user resulted in:

```text
Permission denied
```

### Resolution

* Confirmed permissions were intentionally restrictive
* Accessed backups using `sudo`

### Lesson

> Backup data should be harder to access than live data.

This aligns with real security and compliance practices.

---

## 6. systemd Timers Are Preferable to cron

### What Happened

Automation initially considered cron for backups.

systemd timers were chosen instead.

### Benefits Observed

* Unified logging with `journalctl`
* Clear service/timer separation
* Better handling of missed runs (`Persistent=true`)

### Lesson

> systemd provides better observability and control for infrastructure tasks.

---

## 7. Documentation Prevents Drift

### What Happened

As the lab grew:

* Configuration decisions accumulated
* Context was easy to lose

### Resolution

* Documented architecture, operations, automation, and lessons
* Used documentation to guide future decisions

### Lesson

> Documentation is part of the system.

Without it, operational intent degrades over time.

---

## Final Reflection

This lab reinforced that:

* Most problems are not tool failures, but **design assumptions**
* Small decisions (permissions, execution context) have large effects
* Real systems require iteration, rollback, and verification

The most valuable outcome was not the final configuration, but the operational judgment developed along the way.
