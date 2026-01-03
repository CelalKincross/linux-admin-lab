# Multi-User Research Computing Lab

> A demonstration of Linux system administration skills for academic research computing environments

## Overview

This project simulates a small academic research computing environment designed to showcase operational competency in multi-user Linux administration, automation, backup/recovery workflows, and technical documentation. Built as a portfolio piece for research IT roles, it demonstrates systematic thinking and sustainable operational practices.

## Architecture

The lab consists of three Ubuntu Server VMs with clearly separated responsibilities:
- **lab-admin**: Primary administrative server for user management, shared storage, and automation
- **lab-compute**: Dedicated compute node for research workloads
- **lab-backup**: Backup and archive server for data protection

For detailed architecture documentation, see [architecture.md](architecture.md)

## Project Structure

```
linux-admin-lab/
├── README.md                 # This file
├── architecture.md           # System design and rationale
├── docs/                     # Technical documentation
│   ├── permissions.md        # User & group management
│   ├── services.md           # systemd service management
│   ├── backup_recovery.md    # Backup workflows
│   ├── onboarding.md         # User onboarding procedures
│   └── daily_ops.md          # Operational procedures
├── logs/                     # Daily progress tracking
│   ├── day1.md              # Environment setup
│   ├── day2.md              # Multi-user administration
│   └── ...
├── automation/              # Python automation scripts
├── configs/                 # Configuration templates
├── scripts/                 # Helper scripts
└── ansible/                 # Light automation (optional)
```

## Key Features

- **Multi-user environment** with role-based access controls (faculty, grad students, undergrads)
- **Automated user onboarding** using Python scripts and CSV data
- **Backup and recovery workflows** with rsync and scheduled jobs
- **systemd service management** for operational tasks
- **Comprehensive documentation** designed for research contexts
- **Daily progress logs** demonstrating systematic project execution

## Built With

- Ubuntu Server 22.04 LTS
- Python 3.x
- systemd, rsync, SSH
- Bash scripting
- Git for version control

## Purpose

This lab demonstrates operational skills required for research computing support roles:
- Linux system administration in academic environments
- Multi-user management and permission boundaries
- Automation and scripting for sustainable operations
- Documentation and knowledge transfer
- Project planning and systematic execution

## Project Timeline

Built over 7 days with daily progress tracking. See [logs/](logs/) for detailed daily notes.

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

- ⏳ **Day 5** - Python Automation (Planned)
  - User onboarding scripts
  - Health monitoring automation
  - Scheduled maintenance tasks

- ⏳ **Day 6** - Ansible Configuration (Planned)
  - Light configuration management
  - Repeatable provisioning

- ⏳ **Day 7** - Documentation & Portfolio (Planned)
  - Finalize all documentation
  - Resume bullet mapping
  - Project presentation

## Documentation

All technical documentation is in the [docs/](docs/) directory:
- [Architecture](architecture.md) - System design and rationale
- [REFERENCES.md](REFERENCES.md) - Authoritative documentation links organized by day
- Additional documentation will be added as the project progresses

## Author

Built by Yang Lee as a portfolio demonstration for research computing support roles.

## Development Tools

This project was developed with assistance from [Claude Code](https://claude.com/claude-code), Anthropic's official CLI for Claude, which supported documentation, planning, and project organization tasks.

## License

This project is for educational and portfolio demonstration purposes.
