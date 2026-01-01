# Day 1 - Environment Setup & Architecture

**Date:** 2026-01-01
**Planned Outcomes:** Stable foundation with 3 VMs, SSH access, and architecture documentation

## Morning Session

### Goals
- [x] Install Ubuntu Server on 3 VMs (lab-admin, lab-compute, lab-backup)
- [x] Configure hostnames and networking
- [x] Test SSH access to all VMs
- [x] Update systems and install basic tools

### Execution Notes

**VM Creation:**
- Created 3 Ubuntu Server VMs with clearly defined roles:
  - **lab-admin**: Primary administrative server (2 CPU, 4GB RAM, 40-50GB disk)
  - **lab-compute**: Compute node (2 CPU, 2-4GB RAM, 30-40GB disk)
  - **lab-backup**: Backup & archive server (1-2 CPU, 2GB RAM, 40-60GB disk)

**System Configuration:**
- Set explicit hostnames during installation
- Enabled OpenSSH server on all VMs
- Minimal package installation (clean baseline)
- Created single admin user across all systems

**Initial Hardening:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y vim curl wget git
sudo timedatectl set-timezone America/Toronto
hostnamectl  # Verified correct hostname
```

### Blockers/Issues
None - VMs configured successfully on first attempt

## Afternoon Session

### Goals
- [x] Verify network connectivity between VMs
- [x] Set up GitHub repository structure
- [x] Create architecture.md documentation
- [x] Establish project organization and logging framework

### Execution Notes

**Network Validation:**
- Verified inter-VM connectivity (ping tests successful)
- Confirmed SSH access from host to all VMs
- Network using NAT/bridged configuration for VM communication

**GitHub Repository:**
- Created `linux-admin-lab` repository
- Initialized git structure
- Created .gitignore for macOS artifacts and reference files

**Documentation:**
- Created comprehensive architecture.md covering:
  - VM roles and specifications
  - Design rationale (reliability, security, clarity)
  - Network architecture
  - Future work roadmap
  - Target use case aligned with job requirements

**Project Organization:**
- Established directory structure for systematic development:
  - `/docs/` - Technical documentation deliverables
  - `/logs/` - Daily progress tracking (this file!)
  - `/automation/` - Python scripts (Day 5)
  - `/configs/` - Configuration templates
  - `/scripts/` - Helper scripts
  - `/ansible/` - Light automation (Day 6)

### Blockers/Issues
None - All Day 1 objectives completed

## End of Day Summary

**Completed:**
- ✅ All 3 VMs boot cleanly and are accessible via SSH
- ✅ Hostnames correctly configured (lab-admin, lab-compute, lab-backup)
- ✅ GitHub repo created with proper structure
- ✅ architecture.md written and committed
- ✅ Project directory structure established
- ✅ Daily logging framework implemented

**Deferred/Modified:**
- None - Day 1 completed as planned

**Tomorrow's Focus (Day 2):**
- Multi-user Linux administration (MOST IMPORTANT)
- Create users and groups (faculty, grad, undergrad, admin)
- Set up directory structure (/data/shared, /data/projects, /data/archive)
- Apply role-based permissions
- Test access controls as different users
- Document in docs/permissions.md

**Key Learnings:**
- Clean VM separation from the start makes role assignment clear
- Explicit hostname configuration during install avoids later confusion
- Architecture documentation is as important as implementation
- Daily logging framework demonstrates systematic approach to project execution

## Technical Details for Reference

**VM Specifications Summary:**
| VM | Role | CPU | RAM | Disk | Primary Function |
|---|---|---|---|---|---|
| lab-admin | Administrative | 2 | 4GB | 40-50GB | User mgmt, shared storage, automation |
| lab-compute | Compute | 2 | 2-4GB | 30-40GB | Research workloads |
| lab-backup | Backup | 1-2 | 2GB | 40-60GB | Backup & recovery |

**Key Commands Used:**
```bash
# System updates
sudo apt update && sudo apt upgrade -y

# Basic tool installation
sudo apt install -y vim curl wget git

# Timezone configuration
sudo timedatectl set-timezone America/Toronto

# Hostname verification
hostnamectl

# Network connectivity tests
ping lab-admin
ping lab-compute
ping lab-backup

# Git initialization
git init
git add .
git commit -m "initial commit message"
```

**Next Session Preparation:**
- Review user/group creation commands (useradd, groupadd, usermod)
- Plan directory structure for /data hierarchy
- Review permission concepts (owner, group, other; rwx)
- Prepare test scenarios for permission validation
