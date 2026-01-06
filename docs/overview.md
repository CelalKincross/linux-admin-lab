# Linux Research Computing Lab

## Overview

This project is a hands-on Linux system administration lab designed to simulate a small **research computing environment** similar to what you would find in a university Computer Science department.

The goal of the lab is not to demonstrate isolated commands, but to design, build, operate, troubleshoot, and document a **realistic multi-node environment** with shared storage, controlled access, backups, and automation.

This lab was built to practice and demonstrate skills relevant to research computing support, Linux system administration, and infrastructure operations.

---

## Architecture

The environment consists of three Linux virtual machines:

* **lab-admin**
  Administrative node responsible for:

  * User and group management
  * Authoritative research storage (`/research`)
  * SSH access control

* **lab-compute**
  Compute node that:

  * Mounts shared research storage over NFS
  * Enforces group-based access to project data
  * Runs health checks for required storage availability

* **lab-backup**
  Backup node responsible for:

  * Pull-based backups of research data
  * Snapshot-style retention using `rsync --link-dest`
  * Automated backups using systemd timers

All nodes run Ubuntu Server on ARM (aarch64) and communicate over a private virtual network using SSH key authentication.

---

## Key Features

* Multi-user Linux environment with realistic group and permission models
* Shared research storage using NFS with setgid semantics
* Strict SSH hardening with key-only authentication
* Pull-based, snapshot-style backups with retention
* Systemd-based automation (services, timers, automount)
* Configuration management using Ansible
* Journald-based logging and verification

---

## Technologies Used

* **Linux** (Ubuntu Server 24.04 LTS)
* **SSH** (key-based authentication, hardened configuration)
* **NFSv4** (shared research storage)
* **rsync** (snapshot-style backups with hard links)
* **systemd** (services, timers, automount)
* **Ansible** (idempotent configuration and deployment)
* **Git** (documentation and change tracking)

---

## Backup & Restore Model

Backups are designed with the following principles:

* Backups are **pulled** from the admin node (never pushed)
* Backup storage is **root-only** on the backup server
* Snapshots appear as full backups but share unchanged data via hard links
* A fixed retention policy keeps the most recent snapshots

A restore test was performed by restoring individual files from snapshot storage into a temporary directory to verify integrity and permissions.

---

## Automation

Automation is implemented incrementally:

* Baseline state is declared using Ansible playbooks
* Scripts and systemd units are deployed idempotently
* Handlers ensure services reload only when configuration changes
* Timers are used instead of cron for better observability

---

## Why This Lab

This lab was built to reflect **real operational constraints**, not just idealized examples:

* Permissions are intentionally restrictive
* Backup access bypasses user permissions safely using scoped sudo rules
* SSH hardening required a bootstrapping workflow
* Systemd automount behavior influenced monitoring and testing

These challenges were intentionally worked through and documented.

---

## Repository Structure

```
.
├── ansible/
│   ├── inventory.ini
│   ├── playbooks/
│   └── files/
├── docs/
│   ├── architecture.md
│   ├── operations.md
│   ├── automation.md
│   └── lessons-learned.md
└── README.md
```

---

## Status

This lab is complete and functional. Future enhancements may include:

* Centralized authentication (LDAP/AD)
* Monitoring dashboards
* Expanded backup verification

---

## Author

Built and maintained by **Yanglee** as a practical Linux systems administration project.
