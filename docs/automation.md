# Automation

This document explains how automation was introduced into the Linux Research Computing Lab, **why it was added incrementally**, and how tools like Ansible and systemd were used in a controlled, production-aligned way.

The emphasis is on **intentional automation**, not maximum abstraction.

---

## Automation Philosophy

Automation was introduced **after** manual configuration and troubleshooting.

This was intentional.

Reasons:

* Manual setup builds understanding of failure modes
* Automation should encode *known-good state*, not guess behavior
* Debugging is easier when you understand the underlying commands

This mirrors real operational practice in research computing environments.

---

## Configuration Management with Ansible

### Why Ansible

Ansible was chosen because:

* Agentless (SSH-based)
* Declarative and idempotent
* Widely used in academic and research IT
* Easy to audit and document

Ansible is used to **declare state**, not to replace system understanding.

---

## Inventory Design

Inventory groups represent **roles**, not individual machines.

Example:

```ini
[admin]
lab-admin

[compute]
lab-compute

[backup]
lab-backup

[all:vars]
ansible_user=yanglee
ansible_python_interpreter=/usr/bin/python3
```

This allows:

* Targeted automation (e.g., compute-only tasks)
* Clear intent when reading playbooks
* Easy expansion to additional nodes

---

## Baseline vs Scoped Playbooks

Automation is intentionally split into:

### Baseline Tasks

Applied broadly to all nodes:

* Common packages
* Directory existence
* Service enablement

These tasks establish a **minimum known-good state**.

### Scoped Tasks

Applied only where appropriate:

* NFS mounts on compute nodes
* Backup services on backup nodes
* Health checks where storage is required

This avoids accidental configuration drift.

---

## Idempotency

All Ansible tasks are written to be **idempotent**:

* Re-running playbooks produces no unintended changes
* `changed=0` indicates convergence
* Failures indicate real problems, not noise

Example:

```yaml
- name: Ensure /research directory exists
  file:
    path: /research
    state: directory
    owner: root
    group: researchers
    mode: "2775"
```

---

## Privilege Escalation

Administrative tasks require root privileges.

Ansible uses:

```yaml
become: true
```

Combined with a controlled sudo policy:

```text
yanglee ALL=(ALL) NOPASSWD:ALL
```

This allows automation without interactive prompts while keeping access auditable.

---

## Deploying Scripts and Services

Operational scripts are treated as **managed artifacts**:

* Stored in the Ansible repository under `files/`
* Deployed to `/usr/local/bin`
* Permissions explicitly declared

Systemd units are deployed similarly and reloaded via handlers.

Example handler:

```yaml
handlers:
  - name: reload systemd
    command: systemctl daemon-reload
```

Handlers ensure services reload **only when configuration changes**.

---

## systemd Integration

systemd is used instead of cron for:

* Timers
* Health checks
* Backup automation

Advantages:

* Unified logging via journald
* Dependency awareness
* Better failure visibility

Example:

```bash
systemctl list-timers
journalctl -u research-backup.service
```

---

## What Was Not Automated (By Design)

Some tasks were intentionally left manual:

* Initial SSH key bootstrapping
* Emergency access paths
* Exploratory troubleshooting

Reason:

* These actions are rare
* Automation would add complexity without benefit
* Manual execution is safer for edge cases

---

## Summary

Automation in this lab:

* Encodes operational intent
* Reduces repetition, not understanding
* Is scoped, inspectable, and reversible

This reflects how automation is responsibly introduced in real research computing environments.
