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

**Dual Purpose:**
1. **Portfolio Demonstration** - Showcase operational skills for research computing support roles
2. **Learning Lab** - Comprehensive, hands-on learning environment for Linux administration and Ansible

This lab demonstrates:
- Linux system administration in academic environments
- Multi-user management and permission boundaries
- Automation and scripting for sustainable operations
- Documentation and knowledge transfer
- Project planning and systematic execution

## Learning Materials

This project includes comprehensive learning resources:
- **[LEARNING.md](LEARNING.md)** - Learning journal and progress tracking
- **[learning/concepts/](learning/concepts/)** - Detailed concept explanations
- **[learning/exercises/](learning/exercises/)** - Hands-on practice exercises
- **[learning/cheatsheets/](learning/cheatsheets/)** - Command reference guides
- **[PORTFOLIO.md](PORTFOLIO.md)** - Job application mapping and interview prep

## Project Timeline

Built over 7 days with daily progress tracking. See [logs/](logs/) for detailed daily notes.

## Documentation

All technical documentation is in the [docs/](docs/) directory:
- [Architecture](architecture.md) - System design and rationale
- Additional documentation will be added as the project progresses

## Author

Built by Yang Lee as a portfolio demonstration for research computing support roles.

## License

This project is for educational and portfolio demonstration purposes.
