# Learning Journal - Linux Administration & Ansible

> This project is both a portfolio piece and a comprehensive learning lab for Linux system administration and automation.

## Learning Goals

### Linux Administration
- ✅ VM setup and system configuration
- ⏳ Multi-user management (users, groups, permissions)
- ⏳ systemd service management
- ⏳ SSH hardening and key-based authentication
- ⏳ Storage management and filesystem operations
- ⏳ Backup and recovery workflows
- ⏳ Process management and monitoring
- ⏳ Log management (journalctl, syslog)
- ⏳ Network configuration and troubleshooting
- ⏳ Security best practices

### Python Automation
- ⏳ System administration scripting
- ⏳ File operations and CSV processing
- ⏳ User provisioning automation
- ⏳ Health check scripts
- ⏳ Scheduled jobs with cron

### Ansible
- ⏳ Ansible fundamentals (inventory, playbooks, modules)
- ⏳ YAML syntax and structure
- ⏳ Idempotency concepts
- ⏳ Variables and facts
- ⏳ Templates (Jinja2)
- ⏳ Handlers and notifications
- ⏳ Roles and organization
- ⏳ Best practices for research IT

### Documentation & Project Management
- ✅ Architecture documentation
- ✅ Daily logging and progress tracking
- ⏳ Technical writing for different audiences
- ⏳ Git workflows and commit conventions

## Learning Structure

Each day follows this pattern:

### 1. Pre-Work (30-45 min)
- Read concept documentation
- Review commands and syntax
- Watch tutorials if needed
- Take notes in learning/concepts/

### 2. Hands-On Implementation (2-3 hours)
- Follow guided exercises
- Build portfolio deliverables
- Experiment and break things safely
- Document what you learn

### 3. Practice & Experimentation (1-2 hours)
- Complete challenge exercises
- Try variations and alternatives
- Troubleshoot intentional problems
- Document solutions

### 4. Reflection (30 min)
- Update learning journal
- Write what you understood
- List remaining questions
- Prepare for next day

## Daily Learning Checkpoints

After each day, you should be able to:

**Day 1:** ✅
- Explain the purpose of each VM in the architecture
- Describe why role separation matters in research IT
- Navigate Ubuntu Server via SSH
- Use basic system administration commands

**Day 2:**
- Create and manage users and groups from command line
- Explain Linux permission model (owner, group, other; rwx)
- Set up directory hierarchies with appropriate permissions
- Test access controls by switching users
- Troubleshoot permission issues

**Day 3:**
- Explain what systemd is and why it matters
- Create and manage systemd services
- Read and interpret logs with journalctl
- Configure SSH for key-based authentication only
- Understand service dependencies

**Day 4:**
- Design backup strategies for different data types
- Implement rsync-based backup workflows
- Schedule jobs with cron
- Perform recovery from backup
- Test disaster recovery scenarios

**Day 5:**
- Write Python scripts for system administration tasks
- Parse CSV files for user provisioning
- Implement error handling in automation scripts
- Create reusable functions for common tasks
- Schedule Python scripts via cron

**Day 6:**
- Explain when to use Ansible vs. shell scripts
- Write Ansible playbooks for system configuration
- Understand inventory files and host groups
- Use Ansible modules appropriately
- Apply idempotency principles

**Day 7:**
- Synthesize all components into operational documentation
- Explain design decisions and trade-offs
- Troubleshoot common issues
- Map technical work to job requirements
- Prepare interview talking points

## Concepts to Master

### Linux Fundamentals
- [ ] File system hierarchy (/etc, /var, /home, /opt, etc.)
- [ ] User and group management (useradd, groupadd, usermod)
- [ ] Permission model (chmod, chown, umask)
- [ ] Special permissions (setuid, setgid, sticky bit)
- [ ] Process management (ps, top, kill, systemctl)
- [ ] Package management (apt, dpkg)
- [ ] Environment variables and shell configuration
- [ ] SSH configuration and security

### systemd
- [ ] Unit files (service, timer, target)
- [ ] Service lifecycle (start, stop, restart, reload)
- [ ] Enabling/disabling services
- [ ] Dependencies and ordering
- [ ] Logging with journal
- [ ] Creating custom services

### Networking
- [ ] IP addressing and subnetting basics
- [ ] DNS configuration
- [ ] Firewall basics (ufw)
- [ ] SSH tunneling
- [ ] Network troubleshooting (ping, netstat, ss)

### Storage & Backup
- [ ] Filesystem types and mounting
- [ ] Disk usage monitoring (df, du)
- [ ] rsync flags and options
- [ ] Backup strategies (full, incremental, differential)
- [ ] Recovery procedures

### Ansible
- [ ] YAML syntax and structure
- [ ] Inventory management (static and dynamic)
- [ ] Modules (apt, user, file, template, service, etc.)
- [ ] Variables and facts
- [ ] Playbook structure
- [ ] Handlers for service restarts
- [ ] Idempotency and state management
- [ ] Ansible vault for secrets
- [ ] Roles and galaxy
- [ ] Best practices and patterns

## Resources

### Official Documentation
- Ubuntu Server Guide: https://ubuntu.com/server/docs
- systemd Documentation: https://systemd.io/
- Ansible Documentation: https://docs.ansible.com/
- rsync Manual: https://linux.die.net/man/1/rsync

### Learning Materials
- Linux Journey: https://linuxjourney.com/
- Ansible for DevOps (book) - Jeff Geerling
- The Linux Command Line (book) - William Shotts

### Practice Environments
- Your 3 VMs (safe to break and rebuild!)
- Linux Foundation free courses
- Overthewire wargames (for command-line practice)

## Questions & Research Topics

As you work, maintain a running list of questions to research:

### Current Questions
- What's the difference between systemctl and service commands?
- When should I use Ansible vs. shell scripts?
- How do sticky bits work on directories?
- What's the best backup rotation strategy for research data?

### Researched & Answered
(Populate as you learn)

## Experiments & Variations

Don't just follow the guide - try these experiments:

### Day 2 Experiments
- What happens if you create a file as one user and try to access as another?
- Can a user in the 'faculty' group access files owned by 'grad' group?
- What's the minimum permission needed to cd into a directory?
- How do setgid directories affect file creation?

### Day 3 Experiments
- What happens if a service's dependencies aren't met?
- Can you create a service that automatically restarts on failure?
- How do you troubleshoot a service that won't start?

### Day 4 Experiments
- What's the performance difference between rsync flags?
- How does rsync handle interruptions?
- What happens if you restore a backup while the system is running?

### Day 5 Experiments
- How do you handle errors when a user already exists?
- What's the best way to validate CSV input?
- How do you make scripts idempotent?

### Day 6 Experiments
- What happens if you run a playbook twice?
- How does Ansible handle failures on one host in a multi-host inventory?
- When does Ansible actually change something vs. reporting "ok"?

## Common Mistakes & How to Fix Them

(You'll populate this as you encounter issues)

### Permissions
- **Mistake:**
- **Solution:**
- **Lesson:**

### systemd
- **Mistake:**
- **Solution:**
- **Lesson:**

### Ansible
- **Mistake:**
- **Solution:**
- **Lesson:**

## Knowledge Checks

Test yourself before moving to the next day:

### After Day 2
1. Explain the output of `ls -la` in detail
2. Write a command to create a user with specific UID and home directory
3. Calculate the permission number for rwxr-x---
4. How would you give a group write access to an existing directory?

### After Day 3
1. Write a systemd service file from scratch
2. Explain the difference between `systemctl start` and `systemctl enable`
3. How do you view the last 50 lines of a service's logs?
4. What's the purpose of After= and Wants= in a service file?

### After Day 4
1. Write an rsync command that excludes .git directories
2. How do you schedule a job to run every day at 2am?
3. What's the difference between a cron job and a systemd timer?
4. How would you test a backup without actually running it?

### After Day 5
1. Write a Python script that creates a user if it doesn't exist
2. How do you make a script executable and run it via cron?
3. What's the difference between subprocess.run() and os.system()?
4. How do you handle command failures in Python?

### After Day 6
1. Write a playbook to install nginx and ensure it's running
2. Explain what "idempotent" means with an example
3. When should you use a handler vs. running a task directly?
4. How do you pass variables to a playbook?

## Progress Tracking

Date | Topic | Confidence (1-5) | Notes
-----|-------|------------------|------
2026-01-01 | VM Setup | 4 | Comfortable with basic setup, need more practice with networking
2026-01-01 | Git Workflow | 4 | Understanding commit conventions, need practice with branching

## Next Steps

When you complete this 7-day lab:
- [ ] Rebuild the entire lab from scratch without reference (ultimate test!)
- [ ] Add monitoring with Prometheus/Grafana
- [ ] Implement centralized logging
- [ ] Add configuration management with Ansible roles
- [ ] Create a disaster recovery runbook
- [ ] Set up automated testing for your Ansible playbooks
