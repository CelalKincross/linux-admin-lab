# Portfolio - Technical Skills Demonstration

> Connecting lab implementation to professional requirements

## Resume Bullets

### 1. Linux System Administration
Built and administered a multi-user Linux research computing environment with role-based access controls, shared project storage, and clear separation of administrative, compute, and backup responsibilities across 3 Ubuntu Server VMs. Implemented setgid-based collaboration model for automatic group ownership inheritance, enabling seamless file sharing among research team members. Designed layered access control with general collaboration directory (`/research`, 2775) and project-specific isolation (`/research/project1`, 2770) to balance openness and data protection.

**Evidence:**
- [architecture.md](architecture.md) - System design with 3-VM separation of concerns
- [docs/permissions.md](docs/permissions.md) - Comprehensive access control implementation with setgid directories
- [logs/day1.md](logs/day1.md) - 4 troubleshooting scenarios with root cause analysis
- [logs/day2.md](logs/day2.md) - Multi-user administration implementation and validation

---

### 2. Automation & Scripting
Designed and implemented automated user onboarding and system maintenance workflows using Python and Bash, including CSV-based user provisioning, disk health monitoring, and scheduled cleanup jobs.

**Evidence:**
- [automation/](automation/) - Python automation scripts
- [docs/onboarding.md](docs/onboarding.md) - User provisioning procedures
- Cron job configurations for scheduled tasks

---

### 3. Service Management
Managed Linux services using systemd including SSH hardening, service creation, dependency configuration, and troubleshooting using journalctl for log analysis.

**Evidence:**
- [docs/services.md](docs/services.md) - systemd service management
- Custom systemd service examples
- SSH configuration for key-based authentication

---

### 4. Backup & Recovery
Implemented backup and recovery workflows using rsync and scheduled jobs, including disaster recovery procedures and data protection strategies for research data.

**Evidence:**
- [docs/backup_recovery.md](docs/backup_recovery.md) - Backup procedures
- rsync configuration and scheduling
- Recovery testing documentation

---

### 5. Documentation & Knowledge Transfer
Produced comprehensive technical documentation designed for research contexts, including system architecture, operational procedures, troubleshooting guides, and user onboarding materials.

**Evidence:**
- All documentation in [docs/](docs/)
- [logs/](logs/) demonstrating systematic project execution
- Clear, audience-appropriate writing throughout

---

### 3. SSH Hardening & Access Control (Day 3)
Configured SSH security controls to restrict administrative access and enforce key-based authentication. Implemented group-based SSH access restrictions (`AllowGroups`), disabled password and PAM authentication, and validated effective configuration using `sshd -T`. Separated control-plane access (admin-only) from compute-plane access (researchers allowed).

**Evidence:**
- [logs/day3.md](logs/day3.md) - SSH hardening implementation
- Modular SSH configuration using `/etc/ssh/sshd_config.d/` for maintainability
- Distinction between authentication methods (hardening) and policy enforcement
- Troubleshooting PAM re-enabling password prompts despite `PasswordAuthentication no`

---

### 4. Shared Storage with NFS (Day 4)
Deployed centralized NFS storage to provide transparent shared filesystem access across compute nodes. Configured `/research` directory on lab-admin as authoritative storage server, exported via NFS with appropriate security options (`rw,sync,no_subtree_check`), and mounted on lab-compute with resilient automount configuration (`_netdev,x-systemd.automount`) to prevent boot blocking. Validated server-side permission enforcement across NFS, confirming setgid inheritance and project-level isolation work transparently over the network.

**Evidence:**
- [logs/day4.md](logs/day4.md) - NFS implementation and validation
- NFS export configuration in [configs/nfs/](configs/nfs/) (reference)
- Permission testing as different users using `sudo -u`
- Non-blocking mount strategy with systemd automount

---

### 5. Operational Automation with systemd (Day 5)
Designed and deployed custom systemd services and timers for automated health monitoring and backup operations. Created oneshot health check service on lab-compute to verify `/research` mount availability every 5 minutes, logging results via journald with dedicated tags. Implemented snapshot-style backup automation on lab-admin using rsync with `--link-dest` for space-efficient daily snapshots, 7-day retention policy, and automated cleanup. Validated restore procedures to ensure backup integrity.

**Evidence:**
- [logs/day5.md](logs/day5.md) - systemd services, timers, and backup automation
- [scripts/check-research.sh](scripts/check-research.sh) - Health check automation
- [scripts/backup-research.sh](scripts/backup-research.sh) - Snapshot-style backup with retention
- [configs/systemd/](configs/systemd/) - Service and timer unit files
- Troubleshooting systemd automount behavior during failure testing
- Understanding of `Type=oneshot`, timer scheduling, and journald logging

---

### 6. Configuration Management with Ansible (Day 6)
Implemented Ansible configuration management for multi-server Linux environment, transitioning from manual SSH operations to declarative playbooks. Designed role-based inventory structure separating admin, compute, and backup nodes. Progressed from ad-hoc commands to idempotent playbooks using declarative modules (apt, file, group, service) instead of command/shell. Understood critical distinction between `command` module (non-idempotent) and declarative modules (idempotent state enforcement).

**Evidence:**
- [logs/day6.md](logs/day6.md) - Ansible fundamentals and configuration management
- [ansible/inventory.ini](ansible/inventory.ini) - Role-based host inventory
- [ansible/modules-playbook.yml](ansible/modules-playbook.yml) - Idempotent automation playbook
- Troubleshooting shell pipes with `command` module vs `shell` module
- Understanding of control node architecture (Mac) managing managed nodes (VMs)

---

### 7. Backup & Disaster Recovery (Day 7)
Designed and implemented off-host backup architecture using pull-based model where dedicated backup server (lab-backup) retrieves snapshots from production systems. Deployed snapshot-style backups with rsync `--link-dest` for space-efficient daily snapshots with 7-day retention policy and automated cleanup. Configured SSH trust model with key-based authentication and restricted sudo privileges (NOPASSWD for rsync only) to enable automated pulls while maintaining security boundaries. Implemented systemd timer automation on backup server for hands-off operation with centralized logging via journald.

**Evidence:**
- [logs/day7.md](logs/day7.md) - Off-host backup implementation and architecture
- [scripts/backup-research.sh](scripts/backup-research.sh) - Pull-based snapshot backup script
- [configs/systemd/](configs/systemd/) - systemd timer and service units for automation
- Understanding of pull vs push backup models for security isolation
- SSH trust configuration with privilege restriction for automation
- Snapshot retention using hard-linking to minimize storage overhead

---

### 8. Documentation & Technical Writing
Produced comprehensive technical documentation designed for research computing contexts, including system architecture, operational procedures, troubleshooting guides, and daily progress logs. Created both implementation documentation (how-to guides) and conceptual documentation (design philosophy, architectural decisions, operational philosophy) demonstrating ability to communicate at multiple levels - from tactical commands to strategic rationale. Maintained clear separation between public portfolio materials and private interview preparation.

**Evidence:**
- [docs/architecture.md](docs/architecture.md) - Design philosophy, trust boundaries, and architectural trade-offs
- [docs/automation.md](docs/automation.md) - Automation philosophy and incremental approach rationale
- [docs/operations.md](docs/operations.md) - Day-to-day operational workflows and commands
- [docs/overview.md](docs/overview.md) - Project overview with technology justifications
- [docs/permissions.md](docs/permissions.md) - Comprehensive permission model documentation
- [docs/lessons-learned.md](docs/lessons-learned.md) - Documented mistakes, edge cases, and operational judgment
- [architecture.md](architecture.md) - System design quick reference with VM specifications
- [logs/](logs/) - Seven days of detailed progress tracking with troubleshooting scenarios
- [learning/cheatsheets/](learning/cheatsheets/) - Command reference materials
- [REFERENCES.md](REFERENCES.md) - Authoritative documentation links organized by topic

---

### 9. Project Planning & Execution
Planned and executed a 7-day lab build with daily progress tracking, demonstrating project management discipline and systematic problem-solving approach. Documented 15+ real troubleshooting scenarios encountered during implementation (SSH TTY allocation, hostname mapping errors, systemd automount confusion, Ansible shell module limitations, group dependency failures, pull-based backup architecture decisions).

**Evidence:**
- [logs/day1.md](logs/day1.md) through [logs/day7.md](logs/day7.md) - Daily progress with troubleshooting
- Structured project organization with separation of public portfolio and private learning materials
- Clear milestone tracking showing systematic execution
- Each day includes "Key Learnings" and "Troubleshooting Notes" sections
