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
## 1. CD-ROM Unmount Warning After Ubuntu VM Install
# Issue:
Installer reported failure to unmount installation media

# Cause:
ISO still attached to VM virtual CD drice

# Resolution:
Detached ISO form VM config

# Lesson:
Post-Install cleanup matters to avoid boot/mount isssues

## 2. Incorrect Hostname/IP Mapping 
# Issue: 
Two VMs had their IP addresses mapped to the wrong hostnames

# Cause:
Manual edits to /etc/hosts without validations of host to ip mappings 

# Resolution: 
Corrected mappings on all VMs then verified vis SSH

# Lesson:
Name resolution needs to be validated early
Automate

## 3. SSH Host Key Verification Failure
# Issue: 
After correcting hostname to IP mappings in /etc/hosts, SSH connections failed with a *remote host identication has changed warning*  

# Cause:
SSH caches host keys per hostname. Changing the IP associated with a hostname caused a mismatch between the stored key and the acutal host. 

# Resolution:
Removed stale entries using:
```bash
ssh-keygetn -R <hostname>
```
and re-established trust on next connection

# Lesson: 
Hostname/IP consistancy matters, and SSH host key warnings are a security feature, not an error. 

## 4. SSH + sudo Failing in Centralized Command loop
# Issue; 
Running sudo commands via SSH loop faile with: 
*a terminal is required to read the password*

# Cause: 
SSH non-interactive commands do not allocate a TTY by default; sudo requires a TTY to prompt credentials
```bash
for host in lab-compute lab-admin lab-backup; do
echo "Setting timezone on $host"
ssh $host "sudo timedatectl set-timezone Asia/Taipei" # preferred timezone at time of creation
done
```
the sudo command requires a terminal 

# Resolution: 
Re-ran commands using -t flag for the TTY:
```bash
ssh -t $host "sudo ..."
```

# Lesson:
Privilege escalation behavior must be considered when executing remote or automated commands. 

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
