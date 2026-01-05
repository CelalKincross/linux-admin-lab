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

### 6. Project Planning & Execution
Planned and executed a 7-day lab build with daily progress tracking, demonstrating project management discipline and systematic problem-solving approach. Days 1-2 complete (environment setup and multi-user administration), with documented troubleshooting of 4 real issues encountered during implementation.

**Evidence:**
- [logs/day1.md](logs/day1.md) - Environment setup with troubleshooting documentation (SSH TTY issues, hostname mapping errors)
- [logs/day2.md](logs/day2.md) - Multi-user administration with problem-first learning approach
- Structured project organization with separation of public portfolio and private learning materials
- Clear milestone tracking showing systematic execution
