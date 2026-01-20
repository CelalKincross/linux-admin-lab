# Research Computing Lab – Architecture

## Overview
This lab simulates a small academic research computing environment designed to support
multiple users with shared compute and storage resources. The architecture reflects
common patterns found in university research IT environments, with clear separation
of administrative, computational, and backup responsibilities.

> **For detailed architectural philosophy and design rationale**, see [docs/architecture.md](docs/architecture.md)

## Virtual Machines

### lab-admin
Primary administrative server responsible for:
- User and group management (faculty, grad students, undergrads)
- Shared storage and project directories
- Automation scripts for onboarding and maintenance
- System documentation and operational procedures
- SSH access management
- **HPC:** Slurm controller (slurmctld), job accounting (slurmdbd), Prometheus, Grafana

**Specifications:**
- 2 CPU cores
- 4 GB RAM
- 40-50 GB disk

### lab-compute
Simulated compute node used for:
- Running research workloads and computational tasks
- Restricted access for approved users only
- Resource-intensive processing separate from administrative functions
- **HPC:** Slurm worker daemon (slurmd), Node Exporter for metrics

**Specifications:**
- 2 CPU cores
- 2-4 GB RAM
- 30-40 GB disk

### lab-backup
Dedicated backup server responsible for:
- Receiving scheduled backups from lab-admin
- Storing read-only archives
- Data recovery and disaster recovery operations
- Long-term data retention

**Specifications:**
- 1-2 CPU cores
- 2 GB RAM
- 40-60 GB disk

## Design Rationale
This separation reflects common research IT patterns where administrative,
compute, and backup responsibilities are isolated for:
- **Reliability**: Failures in one system don't cascade to others
- **Security**: Role-based access controls limit user exposure
- **Clarity**: Each system has a well-defined purpose and maintenance scope
- **Operational discipline**: Mirrors real-world research computing environments

## Network Architecture
All VMs operate on a shared network with:
- Inter-VM connectivity for data transfer and backup operations
- SSH access for remote administration
- Clearly defined communication patterns between nodes

## Implementation Status

✅ **Core Infrastructure Complete** (Days 1-7)

- **Day 1**: Environment setup and SSH access
- **Day 2**: Multi-user administration with group-based permissions
- **Day 3**: SSH hardening and access control
- **Day 4**: Shared storage with NFS
- **Day 5**: systemd services, timers, and backup automation
- **Day 6**: Ansible configuration management
- **Day 7**: Off-host backup and disaster recovery

✅ **HPC Extension** (Phases 1-2 Complete)

- **Phase 1**: Slurm job scheduling with controller/compute architecture
- **Phase 2**: Prometheus + Grafana monitoring with alerting
- **Phase 3**: Containers (Apptainer/Singularity) — Planned
- **Phase 4**: Ansible automation for HPC — Planned
- **Phase 5**: Software stacks (Spack) — Planned

See [logs/](logs/) for detailed daily progress and [docs/hpc-extension.md](docs/hpc-extension.md) for HPC documentation.

## Target Use Case
This lab is designed to demonstrate operational competency in:
- Linux system administration in a research context
- Multi-user environment management
- **HPC job scheduling and cluster operations**
- **Monitoring, alerting, and failure recovery**
- Service reliability and data protection
- Documentation and operational procedures
- Scalable, maintainable system design
