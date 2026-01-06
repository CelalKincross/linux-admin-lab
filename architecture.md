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

**Specifications:**
- 2 CPU cores
- 4 GB RAM
- 40-50 GB disk

### lab-compute
Simulated compute node used for:
- Running research workloads and computational tasks
- Restricted access for approved users only
- Resource-intensive processing separate from administrative functions

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

✅ **All 7 Days Complete** (2026-01-01 through 2026-01-06)

- **Day 1**: Environment setup and SSH access
- **Day 2**: Multi-user administration with group-based permissions
- **Day 3**: SSH hardening and access control
- **Day 4**: Shared storage with NFS
- **Day 5**: systemd services, timers, and backup automation
- **Day 6**: Ansible configuration management
- **Day 7**: Off-host backup and disaster recovery

See [logs/](logs/) for detailed daily progress and troubleshooting documentation.

## Target Use Case
This lab is designed to demonstrate operational competency in:
- Linux system administration in a research context
- Multi-user environment management
- Service reliability and data protection
- Documentation and operational procedures
- Scalable, maintainable system design
