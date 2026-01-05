# Day 6 - Ansible Configuration Management (2026-01-05)

## Overview

Implemented foundational Ansible automation for the lab environment, transitioning from manual SSH-based operations to declarative configuration management. Established Mac as control node managing all three VMs (lab-admin, lab-compute, lab-backup) using role-based inventory organization.

## Objectives Completed

### Part 1: Ansible Foundations & Control Node Setup
- ✅ Installed Ansible on Mac (control node)
- ✅ Verified passwordless SSH trust to all managed nodes
- ✅ Created static inventory with role-based grouping (`admin`, `compute`, `backup`)
- ✅ Configured `ansible.cfg` for default inventory and host key checking
- ✅ Tested connectivity with `ansible all -m ping` (SUCCESS on all hosts)

**Key Learning**: Ansible's agentless architecture relies entirely on SSH. Control node remains external to managed infrastructure, mirroring real-world admin workflows.

### Part 2: Ad-Hoc Commands & Parallel Execution
- ✅ Practiced ad-hoc commands replacing SSH loops
- ✅ Tested targeted execution by role groups (`ansible admin`, `ansible compute`)
- ✅ Implemented privilege escalation with `--become` flag
- ✅ Compared manual SSH loops vs Ansible one-liners

**Commands Practiced**:
```bash
ansible all -a "uptime"
ansible all -a "df -h"
ansible admin -a "ls -ld /research"
ansible compute -m shell -a "mount | grep research"
ansible all -a "whoami" --become
```

**Key Learning**: Ad-hoc commands provide parallel execution and structured output but lack idempotency. They're useful for one-off checks but not repeatable automation.

### Part 3: First Playbook (YAML Structure)
- ✅ Created `first-playbook.yml` with basic tasks
- ✅ Understood playbook structure: `hosts`, `tasks`, `gather_facts`, `become`
- ✅ Ran playbook with `ansible-playbook` command
- ✅ Interpreted PLAY RECAP output (ok/changed/unreachable/failed)

**Files Created**:
- `ansible/first-playbook.yml` - Basic whoami/uptime checks
- `ansible/first-playbookpriv.yml` - Privilege escalation test

**Key Learning**: Playbooks codify repeatable automation. Each task has a human-readable name and uses modules for structured execution.

### Part 4: Modules & Idempotency (The Critical Shift)
- ✅ Replaced `command` module with declarative modules
- ✅ Implemented `apt` module for package management
- ✅ Used `group` module to ensure researchers group exists
- ✅ Applied `file` module for directory creation with setgid permissions
- ✅ Managed SSH service with `service` module (started/enabled)

**File Created**: `ansible/modules-playbook.yml`

**Modules Used**:
| Module | Purpose | Idempotent? |
|--------|---------|-------------|
| `apt` | Package installation (vim, curl, wget, git) | ✅ Yes |
| `group` | Ensure researchers group exists | ✅ Yes |
| `file` | /research directory with 2775 setgid | ✅ Yes |
| `service` | SSH service running and enabled | ✅ Yes |

**Key Learning - Idempotency**:
- **First run**: `changed=N` (applied configuration)
- **Second run**: `changed=0` (already in desired state)
- Modules check current state before acting, enabling safe repeated execution

**Mental Model Shift**:
```
❌ Imperative:  command: "apt install vim"      (always reports changed)
✅ Declarative: apt: {name: vim, state: present} (only changes if needed)
```

## Files Created

```
ansible/
├── ansible.cfg               # Default inventory, host_key_checking=False
├── inventory.ini             # Role-based host groups with vars
├── first-playbook.yml        # Part 3: Basic command-based tasks
├── first-playbookpriv.yml    # Part 3: Privilege escalation test
└── modules-playbook.yml      # Part 4: Idempotent module-based tasks
```

## Technical Insights

### Inventory Design
- **Role-based grouping** mirrors infrastructure responsibilities
- **`[all:vars]`** sets ansible_user and python_interpreter globally
- **Static inventory** appropriate for small, stable lab environment

### Why Modules Matter
1. **State checking**: Modules inspect current configuration before acting
2. **Idempotency**: Safe to run repeatedly without side effects
3. **Best practices**: Encode proper flags, error handling, and safety checks
4. **Reporting**: Accurate changed/ok status for drift detection

### Command vs Module
- **`command`/`shell`**: Last resort for truly custom logic
- **Modules**: Preferred for all standard operations (packages, files, services)
- **Interview question**: "When would you use shell over a module?" → Only when no module exists

## Workflow Established

```
Control Node (Mac)
    ↓ SSH + Python
Managed Nodes (lab-admin, lab-compute, lab-backup)
    ↓ Execute tasks in parallel
Report back (ok/changed/failed)
```

## Next Steps (Part 5)

- Deploy real automation scripts using Ansible
- Push systemd units and timers
- Implement backup automation via playbooks
- Practice `copy` module for file deployment

## Portfolio Connections

**Resume Bullet - Configuration Management**:
"Implemented Ansible configuration management for multi-server Linux environment, transitioning from manual SSH operations to declarative playbooks. Designed role-based inventory structure and idempotent automation for package management, permission enforcement, and service orchestration across 3 Ubuntu VMs."

**Evidence**:
- Inventory structure with role separation (admin/compute/backup)
- Progression from ad-hoc → playbooks → idempotent modules
- Understanding of control node vs managed node architecture
- `modules-playbook.yml` demonstrating apt, file, group, service modules

## Troubleshooting Notes

### Issue 1: Ad-hoc Commands with Shell Pipelines
**Problem**: `ansible compute -a "mount | grep research"` failed with "bad usage"

**Root Cause**: The default `-a` flag uses the `command` module, which does not invoke a shell. Pipes, redirects, and shell features are not supported.

**Resolution**: Used explicit shell module: `ansible compute -m shell -a "mount | grep research"`

**Learning**: Prefer modules over shell commands. Use `-m shell` only when shell features (pipes, redirects, conditionals) are required.

---

### Issue 2: Ansible Privilege Escalation Password Prompts
**Problem**: `ansible admin -a "apt update" --become` failed with "Missing sudo password"

**Root Cause**: SSH key authentication ≠ passwordless sudo. Ansible cannot respond to interactive sudo prompts.

**Resolution**: Added to `/etc/sudoers`:
```
yanglee ALL=(ALL) NOPASSWD:ALL
```

**Learning**: Automation requires non-interactive privilege escalation. This is a prerequisite for production Ansible deployments.

---

### Issue 3: "changed" Status on Read-Only Commands
**Problem**: Commands like `whoami` and `uptime` reported `changed` status despite not modifying system state.

**Root Cause**: `command` and `shell` modules are not idempotent. Ansible assumes they may change state since it cannot inspect their effects.

**Resolution**: Understood as expected behavior. Can optionally add `changed_when: false` for read-only commands.

**Learning**: "changed" is a signal about Ansible's knowledge of state, not necessarily actual system modification. This is why modules are preferred.

---

### Issue 4: Group Dependency Failure on lab-backup
**Problem**: Playbook failed on lab-backup with "failed to look up group researchers"

**Root Cause**: The `researchers` group existed on lab-admin and lab-compute from Day 2 manual setup, but was missing on lab-backup.

**Resolution**: Added explicit group creation task before file ownership enforcement:
```yaml
- name: Ensure researchers group exists
  group:
    name: researchers
    state: present
```

**Learning**: Identity objects (users, groups) must exist before filesystem ownership is enforced. This scenario mirrors real-world configuration drift across hosts.

---

### Issue 5: SSH Service Reports "changed" Despite Running
**Problem**: Service module reported `changed` even though SSH was already running.

**Root Cause**: Service was running (runtime state OK) but not explicitly enabled at boot (persistent state missing). `enabled: true` caused the state change.

**Resolution**: Understood as expected behavior. Ansible enforces both runtime state AND boot persistence.

**Learning**: `state: started` = "running now", `enabled: true` = "start on boot". Both should typically be set for services.

---

### Issue 6: Command Output Not Visible in Playbooks
**Problem**: `whoami` and `uptime` task outputs were not displayed in playbook execution.

**Root Cause**: Ansible suppresses stdout on successful tasks. Focus is on state convergence, not command output.

**Resolution**: Use `-v` flag for verbose output, or capture with `register` and display with `debug` module:
```yaml
- name: Check uptime
  command: uptime
  register: result

- name: Show uptime
  debug:
    msg: "{{ result.stdout }}"
```

**Learning**: Ansible is a state engine, not an interactive shell. Output visibility is secondary to state enforcement.

## References

- Ansible modules documentation: https://docs.ansible.com/ansible/latest/collections/
- Inventory structure: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
- Playbook best practices: https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
