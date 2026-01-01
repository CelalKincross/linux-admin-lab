# Portfolio Mapping for U of T DGP Research Computing Role

> Connecting technical implementation to job requirements

## Resume Bullets Generated from This Lab

### 1. Linux System Administration
**Bullet:**
Built and administered a multi-user Linux research computing environment with role-based access controls, shared project storage, and clear separation of administrative, compute, and backup responsibilities across 3 Ubuntu Server VMs.

**Maps to job requirement:**
- "Five years of system administration experience in a highly technical and complex heterogeneous IT environment, developing academic computing solutions preferably for a computing academic discipline."

**Evidence:**
- [architecture.md](architecture.md) - System design
- [docs/permissions.md](docs/permissions.md) - Access control implementation
- [logs/](logs/) - Daily progress demonstrating systematic approach

---

### 2. Automation & Scripting
**Bullet:**
Designed and implemented automated user onboarding and system maintenance workflows using Python and Bash, including CSV-based user provisioning, disk health monitoring, and scheduled cleanup jobs.

**Maps to job requirement:**
- "Experience writing, modifying, and correcting scripts on Linux/Unix platform(s)."
- "Clear and demonstrated ability to design, plan, analyze and improve systems, follow good system administration discipline and practice, and operationalize sustainable processes"

**Evidence:**
- [automation/](automation/) - Python automation scripts
- [docs/onboarding.md](docs/onboarding.md) - User provisioning procedures
- Cron job configurations for scheduled tasks

---

### 3. Service Management
**Bullet:**
Managed Linux services using systemd including SSH hardening, service creation, dependency configuration, and troubleshooting using journalctl for log analysis.

**Maps to job requirement:**
- "Operating, analyzing, debugging, maintaining, modifying, upgrading and testing existing DGP Linux... computer networks, servers, workstations"
- "Monitoring systems for problems, determining required course of action and implementing solutions"

**Evidence:**
- [docs/services.md](docs/services.md) - systemd service management
- Custom systemd service examples
- SSH configuration for key-based authentication

---

### 4. Backup & Recovery
**Bullet:**
Implemented backup and recovery workflows using rsync and scheduled jobs, including disaster recovery procedures and data protection strategies for research data.

**Maps to job requirement:**
- "Experience with... backups, research programming, computational clusters, security, networking"

**Evidence:**
- [docs/backup_recovery.md](docs/backup_recovery.md) - Backup procedures
- rsync configuration and scheduling
- Recovery testing documentation

---

### 5. Documentation & Knowledge Transfer
**Bullet:**
Produced comprehensive technical documentation designed for research contexts, including system architecture, operational procedures, troubleshooting guides, and user onboarding materials.

**Maps to job requirement:**
- "Writing technical documentation as required"
- "Excellent verbal and written communication and interpersonal skills"
- "Ability to communicate with both technical and non-technical people"

**Evidence:**
- All documentation in [docs/](docs/)
- [logs/](logs/) demonstrating systematic project execution
- Clear, audience-appropriate writing throughout

---

### 6. Project Planning & Execution
**Bullet:**
Planned and executed a 7-day lab build with daily progress tracking, demonstrating project management discipline and systematic problem-solving approach.

**Maps to job requirement:**
- "Demonstrated leadership skills with experience providing project leadership"
- "Organized" and "detail-oriented"
- "Clear and demonstrated ability to design, plan, analyze and improve systems"

**Evidence:**
- [logs/](logs/) - Daily progress logs
- Structured project organization
- Clear milestone tracking and completion

---

## Interview Preparation

### Technical Deep-Dive Questions I Can Answer

#### 1. "Walk me through your user permission strategy"
**Answer:**
I designed a three-tier permission model reflecting typical research lab hierarchy:

- **Faculty group**: Full read/write access to shared research data and all project directories
- **Grad student group**: Read/write to their assigned projects, read-only to shared data
- **Undergrad group**: Read-only access to designated directories

I used setgid on project directories to ensure new files automatically inherit the correct group ownership, preventing permission drift. Archive directories are set to 555 (read-only) to protect historical data.

**Technical details:**
- /data/shared: 775 permissions with faculty:grad ownership
- /data/projects/projectA: 770 with setgid bit (2770)
- /data/archive: 555 for immutability

**Evidence:** [docs/permissions.md](docs/permissions.md)

---

#### 2. "How did you implement backup and recovery?"
**Answer:**
I implemented a rsync-based backup system from lab-admin to lab-backup:

- Nightly backups scheduled via cron at 2 AM
- Uses rsync with -avz flags (archive, verbose, compressed)
- --delete flag to mirror source (removes deleted files from backup)
- Logging to /var/log/backup.log for monitoring
- Tested disaster recovery by simulating accidental deletion

**Why rsync?**
- Incremental backups (only changed files)
- Bandwidth efficient
- Preserves permissions and ownership
- Standard tool, no special software needed

**Evidence:** [docs/backup_recovery.md](docs/backup_recovery.md)

---

#### 3. "What's your approach to automating user onboarding?"
**Answer:**
I created a Python script that reads user data from CSV files:

```
username,full_name,group,role
grad_a,Graduate Student A,grad,student
prof_x,Professor X,faculty,professor
```

The script:
1. Validates input (checks for duplicates, required fields)
2. Creates user with appropriate settings (useradd)
3. Assigns to correct group (usermod)
4. Sets up home directory permissions (chmod 700)
5. Generates SSH key if needed
6. Logs all actions for audit trail

**Why Python over Bash?**
- Better CSV parsing
- Easier error handling
- More maintainable for complex logic
- My stronger language

**Evidence:** [automation/user_onboarding.py](automation/user_onboarding.py)

---

#### 4. "How do you troubleshoot a service that won't start?"
**Answer:**
Systematic approach using systemd tools:

1. **Check status:**
   ```bash
   systemctl status servicename
   ```
   Look for error messages and exit codes

2. **Check logs:**
   ```bash
   journalctl -u servicename -xe
   ```
   -x shows explanatory messages, -e jumps to end

3. **Verify configuration:**
   - Check unit file syntax
   - Verify dependencies (After=, Requires=)
   - Check paths and permissions

4. **Test manually:**
   - Run the service command directly
   - Check for missing dependencies or config issues

5. **Common issues:**
   - Wrong file permissions
   - Missing dependencies
   - Port already in use
   - Bad configuration syntax

**Evidence:** [docs/services.md](docs/services.md) - troubleshooting section

---

#### 5. "When do you use Ansible vs. shell scripts?"
**Answer:**
I use Ansible for:
- Initial system provisioning (same setup across multiple VMs)
- Configuration management (ensuring consistent state)
- Tasks that benefit from idempotency (safe to re-run)

I use shell scripts/Python for:
- One-off tasks
- Ongoing operational tasks (backups, monitoring)
- Tasks requiring fine-grained control
- Situations where Ansible overhead isn't justified

**In this lab:**
- Ansible: Base package installation, initial user/group setup
- Python/Bash: User onboarding, health checks, backup operations

**Rationale:** This reflects real research IT where Ansible establishes the foundation, but custom scripts handle day-to-day operations.

**Evidence:** [ansible/](ansible/), [automation/](automation/)

---

### Design Decisions I Can Defend

#### 1. Why three VMs instead of two or four?
**Answer:**
Three VMs provide clear role separation without over-complicating:

- **lab-admin**: User management and shared storage separate from compute
- **lab-compute**: Isolates resource-intensive workloads from admin functions
- **lab-backup**: Dedicated backup prevents backup load from affecting production

**Alternative considered:** Two VMs (admin+backup combined)
**Why rejected:** Backup operations can affect disk I/O; separation maintains reliability

**Real-world parallel:** Most research environments separate these concerns for resilience

---

#### 2. Why rsync instead of dedicated backup software?
**Answer:**
rsync is ideal for this environment because:

**Advantages:**
- Already installed on Ubuntu
- Simple to understand and maintain
- Efficient (incremental backups)
- Can be scripted easily
- No licensing or complex setup

**When to use alternatives:**
- Bacula/Amanda: Large-scale environments with tape systems
- Duplicity: Need encryption and cloud backends
- Borg: Need deduplication and compression

**For research lab scale (3 VMs, <1TB data):** rsync is appropriate

---

#### 3. Why Python for automation instead of pure Bash?
**Answer:**
Python provides better structure for complex logic:

**Python advantages:**
- CSV parsing (import csv)
- Better error handling (try/except)
- More readable for complex operations
- Easier to test and maintain
- subprocess module for safe command execution

**Bash advantages:**
- Simpler for linear command sequences
- No dependencies
- Faster for simple operations

**My approach:** Bash for simple scripts (<20 lines), Python for anything with logic, loops, or file parsing

**Evidence:** Both used appropriately in [automation/](automation/) and [scripts/](scripts/)

---

#### 4. Why daily logs in markdown?
**Answer:**
Daily logs demonstrate systematic approach and provide interview material:

**Benefits:**
- Shows project management discipline
- Creates narrative for hiring committee
- Documents decision-making process
- Provides concrete examples for interviews
- Version controlled (git shows daily progress)

**For job application:** Hiring committees value demonstrated organizational skills and documentation discipline, especially in academic environments

---

## Key Talking Points by Topic

### Multi-User Management
- Designed permission model reflecting research hierarchy
- Used setgid for automatic group inheritance
- Implemented read-only archives for data protection
- Tested access controls from each user perspective

### Automation
- Python for complex logic (user provisioning)
- Bash for simple operations (health checks)
- All scripts have error handling and logging
- Idempotent design (safe to re-run)

### Service Management
- Created custom systemd services for operational tasks
- Understand service dependencies and ordering
- Use journalctl for troubleshooting
- Implement handlers for config changes

### Documentation
- Audience-appropriate (researchers vs. sysadmins)
- Focus on "why" not just "what"
- Include examples and troubleshooting
- Keep updated as system evolves

### Project Management
- Daily logging of progress
- Structured approach to complex tasks
- Clear milestone tracking
- Reflective practice (lessons learned)

---

## Strength Differentiators

### 1. Python Background
Most sysadmins are Bash-first; my Python skills enable:
- Better automation for complex workflows
- Easier integration with APIs
- More maintainable code for research teams

### 2. Documentation Discipline
Comprehensive, well-organized documentation demonstrates:
- Communication skills for research context
- Understanding of knowledge transfer importance
- Ability to support non-technical users

### 3. Systematic Approach
Daily logs and structured project execution show:
- Project management capability
- Organized thinking
- Ability to handle complexity

### 4. Learning Demonstration
This self-directed lab shows:
- Initiative and self-motivation
- Ability to quickly acquire new skills
- Research mindset (experiment, document, iterate)

---

## How to Use This Portfolio

### In Cover Letter
"To demonstrate my readiness for the DGP Research Computing Support Specialist role, I built a multi-user Linux research computing environment that simulates the operational patterns described in your posting. This lab includes role-based user management, automated onboarding workflows, backup/recovery procedures, and comprehensive documentation designed for a research context. The project repository is available at [GitHub link]."

### In Resume
Include 3-4 strongest bullets from section above, with GitHub link

### In Interview
- Have GitHub repo open and ready to screen share
- Reference specific files when answering questions
- Use daily logs to show progression and learning
- Demonstrate live if possible (SSH into VMs)

### Follow-Up
- Send GitHub link in thank-you email
- Reference specific documentation relevant to discussion
- Offer to walk through any aspect in more detail

---

## Application Timeline

- **Day 7:** Complete all documentation and polish
- **Day 7 evening:** Final review of all materials
- **Day 8:** Apply for position with completed portfolio
- **Interview prep:** Review this document, practice talking points
- **During interview:** Be ready to screen share GitHub repo

---

## Questions to Ask Them

1. "What's the current approach to multi-user management in DGP?"
2. "How is automation currently used for system administration tasks?"
3. "What documentation standards does the team follow?"
4. "What's the typical project lifecycle for research computing support?"
5. "How does the team balance research support with infrastructure maintenance?"

These questions demonstrate understanding of the role while gathering information about their environment.
