# Multi-User Research Computing Lab

> A demonstration of Linux system administration and HPC skills for academic research computing environments

## Overview

This project simulates a small academic research computing environment designed to showcase operational competency in multi-user Linux administration, HPC job scheduling, cluster monitoring, automation, backup/recovery workflows, and technical documentation. Built as a portfolio piece for research IT and HPC support roles, it demonstrates systematic thinking and sustainable operational practices.

**Now includes HPC Extension:** Slurm job scheduling, Prometheus/Grafana monitoring, and operational failure recovery.

## Architecture

The lab consists of three Ubuntu Server VMs with clearly separated responsibilities:
- **lab-admin**: Primary administrative server, Slurm controller, Prometheus/Grafana monitoring
- **lab-compute**: Dedicated compute node with Slurm worker daemon and node metrics exporter
- **lab-backup**: Backup and archive server for data protection

For detailed architecture documentation, see [architecture.md](architecture.md) and [HPC Extension](docs/hpc-extension.md)

## Project Structure

```
linux-admin-lab/
├── README.md                 # This file
├── architecture.md           # System design and rationale
├── LEARNING.md               # Learning journal and progress tracking
├── PORTFOLIO.md              # Resume bullets and portfolio mapping
├── REFERENCES.md             # Authoritative documentation links by day
├── docs/                     # Technical documentation
│   ├── permissions.md        # User & group management guide
│   ├── hpc-extension.md      # HPC extension overview and phases
│   └── images/               # Architecture diagrams and screenshots
├── logs/                     # Daily progress tracking
│   ├── day1.md              # Environment setup
│   ├── day2.md              # Multi-user administration
│   ├── day3.md              # SSH access control & hardening
│   ├── day4.md              # Shared storage with NFS
│   ├── day5.md              # systemd operations & backup automation
│   ├── day6.md              # Ansible configuration management
│   ├── hpc-day1.md          # HPC: Slurm setup & failure recovery
│   └── hpc-day2.md          # HPC: Prometheus & Grafana monitoring
├── learning/                # Learning materials and references
│   ├── cheatsheets/        # Command reference sheets
│   ├── concepts/           # Concept explanations
│   └── exercises/          # Practice exercises
├── scripts/                 # Bash automation scripts (reference copies)
│   ├── check-research.sh   # Health check for /research mount
│   └── backup-research.sh  # Snapshot-style backup script
├── configs/                 # Configuration file templates
│   ├── systemd/            # systemd service and timer units
│   ├── ssh/                # SSH configuration snippets
│   └── nfs/                # NFS export examples
├── ansible/                 # Ansible automation
│   ├── inventory.ini       # Host inventory
│   ├── ansible.cfg         # Ansible configuration
│   └── *.yml               # Playbooks
└── personal/                # Private materials (gitignored)
    └── interview-prep.md   # Interview preparation
```

## Key Features

### Core Infrastructure (Days 1-7)
- **Multi-user environment** with role-based access controls (faculty, grad students, undergrads)
- **Automated user onboarding** using Python scripts and CSV data
- **Backup and recovery workflows** with rsync and scheduled jobs
- **systemd service management** for operational tasks
- **Comprehensive documentation** designed for research contexts

### HPC Extension
- **Slurm job scheduling** with controller/compute architecture
- **Job accounting** with slurmdbd and MariaDB backend
- **Cluster monitoring** with Prometheus and Grafana dashboards
- **Proactive alerting** (NodeDown detection with alert fatigue prevention)
- **Failure recovery** validation with documented state transitions

## Built With

- Ubuntu Server 22.04 LTS
- Python 3.x
- systemd, rsync, SSH, NFS
- Ansible (configuration management)
- Bash scripting
- Git for version control
- **HPC Stack:** Slurm, MUNGE, slurmdbd, MariaDB
- **Monitoring:** Prometheus, Grafana, Node Exporter

## Purpose

This lab demonstrates operational skills required for research computing and HPC support roles:
- Linux system administration in academic environments
- Multi-user management and permission boundaries
- **HPC job scheduling and cluster operations**
- **Monitoring, alerting, and failure recovery**
- Automation and scripting for sustainable operations
- Documentation and knowledge transfer
- Project planning and systematic execution

## Project Timeline

Built over 7 days with daily progress tracking, plus ongoing HPC extension. See [logs/](logs/) for detailed daily notes.

### Progress

- ✅ **Day 1** - Environment Setup & Architecture (2026-01-01)
  - 3 VMs configured with role separation
  - SSH access and networking established
  - Git repository and documentation framework
  - [View log](logs/day1.md)

- ✅ **Day 2** - Multi-User Administration & Permissions (2026-01-02)
  - User and group management (alice, bob, carol)
  - Group-based access control with setgid directories
  - Layered permission model (general + project isolation)
  - [View log](logs/day2.md) | [View documentation](docs/permissions.md)

- ✅ **Day 3** - SSH Access Control & Hardening (2026-01-03)
  - SSH restriction via AllowGroups (control vs compute separation)
  - SSH key-based authentication for administrators
  - Password authentication disabled on admin nodes
  - Configuration validation with sshd -T
  - [View log](logs/day3.md)

- ✅ **Day 4** - Shared Storage with NFS (2026-01-03)
  - Centralized storage on lab-admin with NFS server
  - lab-compute mounts /research transparently
  - Permission enforcement across NFS (server-side)
  - Persistent, non-blocking mounts with automount
  - [View log](logs/day4.md)

- ✅ **Day 5** - systemd Operations & Backup Automation (2026-01-04)
  - Custom systemd oneshot services (health checks)
  - systemd timers for scheduled execution (replacing cron)
  - Snapshot-style backups with rsync --link-dest
  - Retention policy (7-day rolling snapshots)
  - Restore testing and validation
  - [View log](logs/day5.md)

- ✅ **Day 6** - Ansible Configuration Management (2026-01-05/06)
  - Control node setup (Mac) with role-based inventory
  - Ad-hoc commands for parallel execution across hosts
  - Declarative playbooks with idempotent modules
  - Package, file, group, and service management automation
  - Portfolio documentation completed (scripts, configs, cheatsheets)
  - [View log](logs/day6.md)

- ✅ **Day 7** - Off-Host Backup & Disaster Recovery (2026-01-06)
  - Pull-based backup architecture on dedicated backup server (lab-backup)
  - Snapshot-style backups with rsync --link-dest for space efficiency
  - systemd timer automation for daily backup execution
  - 7-day retention policy with automated cleanup
  - SSH trust model with restricted sudo privileges for security
  - [View log](logs/day7.md)

### HPC Extension

- ✅ **Phase 1** - Slurm Job Scheduling (2026-01-18/19)
  - Slurm controller (slurmctld) on lab-admin, worker (slurmd) on lab-compute
  - MUNGE authentication between nodes
  - Job accounting with slurmdbd and MariaDB
  - Failure injection and recovery validation (node state transitions)
  - [View log](logs/hpc-day1.md)

- ✅ **Phase 2** - Monitoring & Observability (2026-01-19)
  - Node Exporter for host metrics on compute node
  - Prometheus for metrics collection and alerting
  - Grafana dashboard (HPC Cluster Health – Admin View)
  - NodeDown alert with alert fatigue prevention
  - [View log](logs/hpc-day2.md)

- ✅ **Phase 3** - Containers with Apptainer (2026-01-20)
  - Apptainer installation via PPA on compute node
  - Single-file SIF images stored on shared NFS
  - Slurm integration (sbatch + apptainer exec)
  - Shared storage validation with --bind mounts
  - [View log](logs/hpc-day3.md)
- ⬜ **Phase 4** - Ansible Automation for HPC — Planned
- ⬜ **Phase 5** - Software Stacks (Spack) — Planned

## Documentation

### Quick Start
- [README](README.md) - Project overview and status (this file)
- [Architecture](architecture.md) - System design, VM specifications, and implementation status
- [PORTFOLIO.md](PORTFOLIO.md) - Resume bullets and portfolio mapping
- [REFERENCES.md](REFERENCES.md) - Authoritative documentation links organized by day

### Technical Documentation ([docs/](docs/))
- [Overview](docs/overview.md) - Detailed project overview and key features
- [Architecture](docs/architecture.md) - Design philosophy, trust boundaries, and architectural decisions
- [Operations](docs/operations.md) - Day-to-day operational workflows and commands
- [Automation](docs/automation.md) - Automation philosophy and configuration management approach
- [Permissions](docs/permissions.md) - User and group management with detailed permission models
- [Lessons Learned](docs/lessons-learned.md) - Practical lessons, mistakes, edge cases, and design decisions
- [HPC Extension](docs/hpc-extension.md) - Slurm, monitoring, and HPC operations

### Daily Progress Logs ([logs/](logs/))
- Days 1-7: Core infrastructure implementation with troubleshooting scenarios
- HPC Day 1-2: Slurm setup, accounting, failure recovery, monitoring stack

## Author

Built by Yang Lee as a portfolio demonstration for research computing support roles.

## License

This project is for educational and portfolio demonstration purposes.
