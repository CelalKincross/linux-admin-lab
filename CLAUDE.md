# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This is a **portfolio demonstration project** for research computing support roles, NOT a production system. It simulates a small academic research computing environment across 3 Ubuntu Server VMs (lab-admin, lab-compute, lab-backup). All work is completed (Days 1-7) and documented for resume/interview purposes.

**Key Context**:
- Built as a learning project to demonstrate Linux administration competency
- Daily progress logs (logs/day*.md) document real troubleshooting and implementation decisions
- Documentation is audience-aware and designed for research IT contexts
- Personal/private materials are in `personal/` directory (gitignored)

## Architecture Overview

### Three-Node Model
- **lab-admin**: Primary administrative server, NFS storage authority, user management
- **lab-compute**: Compute node consuming shared storage via NFS
- **lab-backup**: Dedicated backup server using pull-based architecture

### Design Philosophy
- **Separation of concerns** - each node has distinct responsibilities
- **Pull-based backups** - backup server controls orchestration and retention
- **Least-privilege access** - role-based permissions, restricted SSH, scoped sudo
- **Operational realism** - mirrors real academic research IT environments

See [docs/architecture.md](docs/architecture.md) for detailed design rationale and trust boundaries.

## VM Access & Operations

### SSH Access
```bash
# Connect to VMs (from macOS host)
ssh yanglee@lab-admin
ssh yanglee@lab-compute
ssh yanglee@lab-backup

# User has NOPASSWD sudo on all nodes
```

### Common Verification Commands
```bash
# Check NFS mounts (on lab-compute)
mount | grep research
df -h | grep research

# Check backup status (on lab-backup)
sudo ls -l /var/backups/research
journalctl -t research-backup --no-pager

# List systemd timers
systemctl list-timers | grep research

# View service logs
journalctl -u research-backup.service --no-pager
journalctl -t research-check --no-pager
```

## Ansible Configuration Management

### Control Node
This repository (on macOS) serves as the Ansible control node. Managed nodes are the 3 Ubuntu VMs.

### Inventory Structure
```ini
# ansible/inventory.ini
[admin]
lab-admin

[compute]
lab-compute

[backup]
lab-backup
```

### Running Ansible Commands
```bash
cd /Users/yanglee/Desktop/linux-admin-lab

# Ad-hoc commands
ansible all -m ping
ansible all -m shell -a "hostname"
ansible admin -m shell -a "df -h" --become

# Run playbooks
ansible-playbook ansible/baseline.yml
ansible-playbook ansible/deploy-research.yml

# Check mode (dry-run)
ansible-playbook ansible/baseline.yml --check
```

**Important**: Use declarative modules (apt, file, group, service) for idempotency, NOT `command` or `shell` modules. See logs/day6.md for rationale.

## Key Technical Patterns

### User & Group Management
- **researchers** group: general research access to `/research`
- **project1** group: restricted access to `/research/project1`
- Users: alice, bob, carol (bob and alice in project1, carol not)

Permissions model:
- `/research`: `2775 root:researchers` (setgid for automatic group inheritance)
- `/research/project1`: `2770 root:project1` (project isolation)

### NFS Shared Storage
- lab-admin exports `/research` via NFSv4
- lab-compute mounts at `/research` using systemd automount (`_netdev,x-systemd.automount`)
- Server-side permission enforcement (client mounts preserve permissions)

### Backup Architecture
- **Pull-based model**: lab-backup initiates connections to lab-admin
- **Snapshot-style**: rsync with `--link-dest` for space-efficient daily snapshots
- **Retention**: 7-day rolling window, automated cleanup
- **Privileged access**: Uses `--rsync-path="sudo rsync"` to read restricted directories
- **Automation**: systemd service + timer, logs to journald

Key scripts (reference copies in `scripts/`):
- `check-research.sh`: Health check for `/research` mount availability
- `backup-research.sh`: On-host backup (Day 5, deprecated by Day 7)
- `backup-research-offhost.sh`: Pull-based backup from lab-backup (Day 7)

### SSH Security Model
- Key-based authentication only (password auth disabled)
- AllowGroups restrictions separate control vs compute access
- Configuration in `/etc/ssh/sshd_config.d/*.conf` for modularity

## Documentation Structure

### Primary Documentation (`docs/`)
- **overview.md**: Detailed project overview and key features
- **architecture.md**: Design philosophy, trust boundaries, architectural decisions
- **operations.md**: Day-to-day operational workflows and commands
- **automation.md**: Automation philosophy and configuration management approach
- **permissions.md**: User and group management with permission models
- **lessons-learned.md**: Practical lessons, mistakes, edge cases, design decisions

### Daily Progress Logs (`logs/`)
- **day1.md through day7.md**: Implementation notes with troubleshooting scenarios
- Each log documents objectives, commands, decisions, and lessons learned
- Contains 15+ real troubleshooting scenarios encountered during implementation

### Learning Materials (`learning/`)
- **cheatsheets/**: Command reference sheets (linux-commands.md)
- **concepts/**: Concept explanations (ansible-fundamentals.md, permissions, etc.)
- **exercises/**: Practice exercises

### Portfolio Materials
- **README.md**: Project overview and quick start
- **PORTFOLIO.md**: Resume bullets mapped to implementation evidence
- **REFERENCES.md**: Authoritative documentation links organized by day
- **architecture.md**: High-level system design with VM specifications

### Configuration Templates (`configs/`)
Reference copies of configuration files (NOT authoritative sources - those live on VMs):
- `systemd/`: Service and timer unit files
- `nfs/`: NFS export examples
- `ssh/`: SSH configuration snippets
- `backup/`: Backup-related configs

## Common Tasks

### Reviewing Implementation Work
When asked about implementation details, always reference:
1. Daily logs (logs/day*.md) for troubleshooting and decision rationale
2. Technical docs (docs/*.md) for conceptual understanding
3. PORTFOLIO.md for resume-relevant skill demonstrations

### Modifying Documentation
- **Daily logs**: These are historical records - only edit for clarity, not content changes
- **Technical docs**: Can be updated to improve clarity or add missing context
- **Portfolio materials**: Keep aligned with implemented work (don't add hypothetical features)

### Ansible Workflow
If modifying Ansible playbooks:
1. Use declarative modules (apt, file, group, service) for idempotency
2. Avoid `command`/`shell` modules unless absolutely necessary
3. Always use `become: true` for privileged operations
4. Test with `--check` before applying changes
5. Reference ansible/modules-playbook.yml for best practices

### Git Commit Style
This project uses conventional commit format:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- Never reference tools in commit messages (professional presentation)

## Important Constraints

### What NOT to Do
1. **Don't modify VM state directly** - User manages VMs, you assist with documentation/planning
2. **Don't add hypothetical features** - This is a completed portfolio project, not active development
3. **Don't treat logs as editable** - Daily logs are historical records showing real work progression
4. **Don't suggest production-level complexity** - This is a learning lab, not enterprise infrastructure

### What TO Do
1. **Help refine documentation** - Improve clarity, fix inconsistencies, suggest better organization
2. **Explain technical concepts** - Help user understand implementation decisions and tradeoffs
3. **Suggest portfolio improvements** - Better resume bullets, interview talking points, evidence mapping
4. **Identify documentation gaps** - Point out missing context or unclear explanations

## Technical Decisions & Rationale

### Why systemd over cron?
- Integrated logging via journald
- Network dependency handling
- Persistent execution (catches up after downtime)
- Better failure visibility via systemctl

### Why pull-based backups?
- Backup server controls scheduling and retention
- Compromised admin node cannot overwrite backup history
- Clear trust model with minimal privileges
- Industry best practice

### Why Ansible?
- Agentless (SSH-based)
- Declarative and idempotent
- Widely used in academic/research IT
- Easy to audit and document

### Why NFS over other storage solutions?
- Matches common academic environments
- POSIX permissions remain meaningful
- Avoids unnecessary complexity for lab scale
- Transparent to applications

## Troubleshooting Reference

Common issues documented in daily logs:

### SSH Issues (Day 3, Day 7)
- Key bootstrap with hardened SSH config requires temporary password auth exception
- Match directives can override PasswordAuthentication settings
- Use `sshd -T` to verify effective configuration

### NFS Mounting (Day 4)
- Use `_netdev,x-systemd.automount` to prevent boot blocking
- Server-side permissions are authoritative
- Test with `sudo -u <user>` to verify access

### Backup Permissions (Day 7)
- Use `--rsync-path="sudo rsync"` for restricted directories
- Sudo rule: `yanglee ALL=(root) NOPASSWD:/usr/bin/rsync`
- Backups are infrastructure - need privileged access

### Ansible Module Selection (Day 6)
- Use `shell` module for pipes/redirects, `command` for simple execution
- Prefer declarative modules (apt, file, group) over command/shell
- Command module is NOT idempotent (always shows "changed")

## File Organization Patterns

```
linux-admin-lab/
├── README.md              # Project overview (start here)
├── PORTFOLIO.md           # Resume bullets with evidence mapping
├── architecture.md        # Quick system design reference
├── REFERENCES.md          # Documentation links by topic
├── LEARNING.md            # Learning journal
├── docs/                  # Technical documentation (conceptual + operational)
├── logs/                  # Daily progress (implementation narrative)
├── learning/              # Learning materials and references
├── scripts/               # Reference copies of operational scripts
├── configs/               # Reference copies of config files
├── ansible/               # Ansible control node configuration
├── personal/              # Private materials (gitignored)
└── .claude/               # Session memory and startup context
```

## Session Context

Check `.claude/STARTUP.md` for the most recent session state, completion status, and next actions. This file is maintained by the session-closer agent and provides quick context for resuming work.

## Additional Notes

- VMs are accessed via SSH, not local filesystem
- Actual configuration files live on VMs, `configs/` directory has reference copies only
- Scripts in `scripts/` are reference copies for portfolio; deployed versions are in VM filesystems
- User yanglee manages VMs; Claude assists with documentation, planning, and understanding
- Project is designed for resume/interview presentation in research computing support roles
