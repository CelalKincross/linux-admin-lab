# Architecture

## Design Philosophy

This lab was intentionally designed to resemble a **small academic research computing environment**, rather than a generic homelab. The emphasis is on **operational realism**, clear trust boundaries, and reproducible administrative workflows.

Key architectural principles:

* Separation of concerns between administration, computation, and backup
* Least-privilege access for users and services
* Pull-based data protection
* Explicit, inspectable automation

---

## Node Roles

### lab-admin (Administrative & Storage Authority)

**Purpose**: Single source of truth for users, permissions, and research data.

Responsibilities:

* Hosts the authoritative `/research` filesystem
* Manages users and groups (researchers, project groups)
* Enforces POSIX permissions and setgid semantics
* Acts as the SSH access control boundary

Rationale:

* Research data ownership and permissions must be centralized
* Avoids configuration drift across compute nodes
* Mirrors how faculty- or lab-owned storage is commonly managed

---

### lab-compute (Research Execution Node)

**Purpose**: Consume shared research data without owning it.

Responsibilities:

* Mounts `/research` via NFS
* Enforces access through inherited permissions
* Runs health checks to ensure required storage is available

Rationale:

* Compute nodes should not own or manage authoritative data
* Fail-fast behavior when required storage is unavailable
* Models real research clusters where compute nodes are disposable

---

### lab-backup (Data Protection Node)

**Purpose**: Protect research data without interacting with live workloads.

Responsibilities:

* Pulls data from lab-admin using SSH
* Maintains snapshot-style backups with retention
* Stores backups in root-only storage
* Automates backups using systemd timers

Rationale:

* Pull-based backups prevent accidental or malicious data pushes
* Backup systems must bypass user-level permissions safely
* Root-only access reflects real backup security models

---

## Trust Boundaries

| Boundary                | Justification                                  |
| ----------------------- | ---------------------------------------------- |
| Users → lab-admin       | Controlled SSH access, no direct backup access |
| lab-compute → lab-admin | Read/write only via NFS permissions            |
| lab-backup → lab-admin  | SSH pull using scoped sudo for rsync           |
| Users → backups         | Explicitly denied                              |

This design ensures:

* Compromise of one node does not cascade
* Backup data cannot be casually browsed
* Permissions remain authoritative on a single system

---

## Storage Model

* `/research` lives **only** on lab-admin
* lab-compute mounts it via NFSv4
* lab-backup never mounts live storage

NFS was chosen because:

* It matches common academic environments
* POSIX permissions remain meaningful
* It avoids introducing unnecessary complexity

Object storage or parallel filesystems were intentionally excluded to keep the lab focused and inspectable.

---

## Backup Architecture

Backups are:

* Pull-based (lab-backup → lab-admin)
* Snapshot-style using `rsync --link-dest`
* Logged via journald
* Retained using a fixed-count policy

Key decision:

* `rsync` runs as root on the source via a tightly scoped sudo rule

This preserves security while ensuring complete backups.

---

## Why Slurm and Monitoring Were Deferred

Slurm and large-scale monitoring were intentionally excluded:

* The job focus emphasizes **support and operations**, not scheduler administration
* User management, storage, backups, and automation are higher signal at this scale
* Adding Slurm without real workloads would reduce clarity

The architecture leaves room for these additions if needed.

---

## Summary

This architecture prioritizes:

* Clarity over novelty
* Correctness over feature count
* Realistic operational constraints

Every design choice was made to reflect how research computing environments are actually operated, not how they are diagrammed in theory.
