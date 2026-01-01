# Research Computing Lab – Architecture

## Overview
This lab simulates a small academic research computing environment designed to support
multiple users with shared compute and storage resources. The architecture reflects
common patterns found in university research IT environments, with clear separation
of administrative, computational, and backup responsibilities.

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

## Future Work
- Multi-user access controls with role-based permissions
- Automated user onboarding from CSV data
- Backup and recovery workflows using rsync
- systemd service management for operational tasks
- Python-based automation for maintenance and health checks
- Comprehensive documentation for lab users and administrators
- Integration of compute node with research workflows

## Target Use Case
This lab is designed to demonstrate operational competency in:
- Linux system administration in a research context
- Multi-user environment management
- Service reliability and data protection
- Documentation and operational procedures
- Scalable, maintainable system design
