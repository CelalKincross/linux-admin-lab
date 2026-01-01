# Ansible Fundamentals

> Learn Ansible for research IT automation - focused, practical, no fluff

## What is Ansible?

**Simple answer:** Ansible automates system administration tasks across multiple servers.

**Why it matters for this job:**
- Research labs often have multiple similar systems
- Reproducible configurations are critical
- Automation saves time and reduces errors
- Documentation through code (playbooks are self-documenting)

## When to Use Ansible (vs. Shell Scripts)

**Use Ansible when:**
- Configuring multiple servers the same way
- You want idempotency (safe to run multiple times)
- Task requires checking current state before acting
- You need structured, readable automation

**Use shell scripts when:**
- One-off task on a single server
- Very simple operations (3-4 commands)
- Need extremely fine-grained control
- Performance is critical (Ansible has overhead)

**For this lab:** We use Ansible lightly on Day 6 for base system setup, but Python/Bash for ongoing operations. This reflects real research IT where Ansible sets the foundation, but custom scripts handle day-to-day tasks.

## Core Ansible Concepts

### 1. Inventory

**What:** List of servers (hosts) Ansible manages

**File:** `inventory.ini` or `hosts`

**Example:**
```ini
[admin]
lab-admin ansible_host=192.168.1.10 ansible_user=ubuntu

[compute]
lab-compute ansible_host=192.168.1.11 ansible_user=ubuntu

[backup]
lab-backup ansible_host=192.168.1.12 ansible_user=ubuntu

[research:children]
admin
compute
backup
```

**What this means:**
- `[admin]` - group name (can target this group in playbooks)
- `ansible_host` - IP address or hostname
- `ansible_user` - SSH user to connect as
- `[research:children]` - meta-group containing other groups

### 2. Playbooks

**What:** YAML files that describe what Ansible should do

**Structure:**
```yaml
---
- name: Configure research lab systems
  hosts: research
  become: yes
  tasks:
    - name: Install essential packages
      apt:
        name:
          - vim
          - git
          - curl
        state: present
        update_cache: yes
```

**Breaking it down:**
- `---` - YAML file start marker
- `name` - Human-readable description
- `hosts: research` - Run on hosts in "research" group
- `become: yes` - Use sudo (become root)
- `tasks` - List of things to do
- `apt` - Ansible module for package management

### 3. Modules

**What:** Pre-built Ansible functions for common tasks

**Common modules you'll use:**

| Module | Purpose | Example |
|--------|---------|---------|
| `apt` | Package management | Install nginx |
| `user` | Create/manage users | Create grad_a user |
| `group` | Create/manage groups | Create faculty group |
| `file` | File/directory operations | Create /data/shared |
| `copy` | Copy files to hosts | Deploy config file |
| `template` | Copy + variable substitution | Dynamic configs |
| `service` | Manage services | Start/enable nginx |
| `systemd` | systemd operations | Create systemd service |
| `lineinfile` | Edit specific line | Change SSH config |
| `shell` | Run shell command | Complex commands |
| `command` | Run simple command | One-off commands |

**Module documentation:**
```bash
ansible-doc apt    # Read apt module docs
ansible-doc -l     # List all modules
```

### 4. Idempotency

**What:** Running the same playbook multiple times produces the same result (no unexpected changes)

**Why it matters:** Safe to re-run automation without breaking things

**Example:**
```yaml
- name: Ensure nginx is installed
  apt:
    name: nginx
    state: present
```

First run: Installs nginx (changed)
Second run: nginx already installed, does nothing (ok)
Third run: nginx already installed, does nothing (ok)

**Non-idempotent (bad):**
```yaml
- name: Add line to file
  shell: echo "text" >> /etc/config
```

First run: Adds line
Second run: Adds line AGAIN (duplicate!)
Third run: Adds line AGAIN (disaster!)

**Idempotent version (good):**
```yaml
- name: Ensure line exists in file
  lineinfile:
    path: /etc/config
    line: "text"
    state: present
```

### 5. Variables

**What:** Values you can reuse in playbooks

**Define in playbook:**
```yaml
---
- name: Example playbook
  hosts: research
  vars:
    research_group: faculty
    data_dir: /data/shared
  tasks:
    - name: Create data directory
      file:
        path: "{{ data_dir }}"
        state: directory
        group: "{{ research_group }}"
```

**Define in inventory:**
```ini
[admin]
lab-admin ansible_host=192.168.1.10 data_disk=/dev/sdb1
```

**Facts (automatic variables):**
```yaml
- name: Show system info
  debug:
    msg: "This system has {{ ansible_memtotal_mb }}MB RAM"
```

### 6. Handlers

**What:** Tasks that run only when notified and only once at the end

**Use case:** Restart service only if config changed

**Example:**
```yaml
---
- name: Configure SSH
  hosts: research
  tasks:
    - name: Update SSH config
      lineinfile:
        path: /etc/ssh/sshd_config
        line: "PermitRootLogin no"
      notify: Restart SSH

  handlers:
    - name: Restart SSH
      service:
        name: ssh
        state: restarted
```

**What happens:**
1. If sshd_config changes, task notifies "Restart SSH" handler
2. Handler runs ONCE at the end (even if multiple tasks notify it)
3. If sshd_config didn't change, handler doesn't run

### 7. Roles

**What:** Organized way to structure playbooks for reuse

**Structure:**
```
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── templates/
    │   └── nginx.conf.j2
    ├── files/
    ├── vars/
    │   └── main.yml
    └── defaults/
        └── main.yml
```

**For this lab:** We won't use roles - keeping it simple with single playbooks

## YAML Syntax Essentials

**Lists:**
```yaml
packages:
  - vim
  - git
  - curl
```

**Dictionaries:**
```yaml
user:
  name: grad_a
  uid: 1001
  group: grad
```

**Strings:**
```yaml
# No quotes needed (usually)
description: This is a string

# Quotes when needed
path: "/data/{{ project }}/files"
```

**Booleans:**
```yaml
become: yes
enabled: true
disabled: false
```

**Comments:**
```yaml
# This is a comment
- name: Install packages  # Inline comment
```

## Running Ansible

### Ad-hoc Commands

**Syntax:**
```bash
ansible <hosts> -m <module> -a "<arguments>"
```

**Examples:**
```bash
# Ping all hosts
ansible research -m ping

# Check disk space
ansible research -m shell -a "df -h"

# Install package on all hosts
ansible research -m apt -a "name=vim state=present" --become

# Create user
ansible admin -m user -a "name=grad_a state=present" --become
```

### Running Playbooks

**Syntax:**
```bash
ansible-playbook <playbook.yml>
```

**Useful flags:**
```bash
# Dry run (check mode - doesn't make changes)
ansible-playbook playbook.yml --check

# Show what would change (with check mode)
ansible-playbook playbook.yml --check --diff

# Run with verbose output
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vvv  # More verbose

# Run on specific hosts
ansible-playbook playbook.yml --limit lab-admin

# Ask for sudo password
ansible-playbook playbook.yml --ask-become-pass
```

## Your First Playbook

**Goal:** Install basic packages on all VMs

**File:** `ansible/playbook_base_setup.yml`

```yaml
---
- name: Base system setup for research lab
  hosts: research
  become: yes

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install essential packages
      apt:
        name:
          - vim
          - git
          - curl
          - wget
          - htop
          - tree
          - rsync
        state: present

    - name: Set timezone
      timezone:
        name: America/Toronto

    - name: Ensure SSH is running and enabled
      service:
        name: ssh
        state: started
        enabled: yes
```

**Run it:**
```bash
cd /Users/yanglee/Desktop/linux-admin-lab/ansible
ansible-playbook -i inventory.ini playbook_base_setup.yml
```

## Common Patterns

### Create User with Home Directory
```yaml
- name: Create graduate student user
  user:
    name: grad_a
    comment: "Graduate Student A"
    shell: /bin/bash
    createhome: yes
    groups: grad
    append: yes
```

### Create Directory with Permissions
```yaml
- name: Create shared project directory
  file:
    path: /data/projects/projectA
    state: directory
    owner: prof_x
    group: faculty
    mode: '0770'
```

### Copy File to Remote Hosts
```yaml
- name: Copy backup script
  copy:
    src: files/backup.sh
    dest: /usr/local/bin/backup.sh
    owner: root
    group: root
    mode: '0755'
```

### Template with Variables
```yaml
- name: Deploy SSH config
  template:
    src: templates/sshd_config.j2
    dest: /etc/ssh/sshd_config
    owner: root
    group: root
    mode: '0644'
  notify: Restart SSH
```

### Install and Start Service
```yaml
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Start and enable nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

### Run Command Only If Condition Met
```yaml
- name: Check if config exists
  stat:
    path: /etc/myapp/config
  register: config_file

- name: Create config if missing
  template:
    src: config.j2
    dest: /etc/myapp/config
  when: not config_file.stat.exists
```

## Best Practices for Research IT

1. **Keep it simple** - Don't over-engineer
2. **Comment everything** - Your colleagues need to understand
3. **Test with --check first** - Dry run before applying
4. **Use handlers for service restarts** - Efficient and safe
5. **Make playbooks idempotent** - Safe to re-run
6. **Version control your playbooks** - Git is your friend
7. **Document why, not just what** - Help future you

## Ansible vs. Shell Scripts Decision Tree

```
Need to configure multiple servers?
├─ Yes → Ansible
└─ No → Shell script (probably)

Task needs to check state before acting?
├─ Yes → Ansible
└─ No → Could go either way

Need it to be idempotent (safe to re-run)?
├─ Yes → Ansible
└─ No → Shell script is fine

Is it a one-time setup task?
├─ Yes → Ansible (documents the setup)
└─ No (ongoing operation) → Shell script or Python

Do non-sysadmins need to read/modify it?
├─ Yes → Ansible (more readable)
└─ No → Either works
```

## Common Mistakes to Avoid

1. **Using `shell` module for everything** - Use specific modules instead
2. **Not testing with --check first** - Always dry run
3. **Forgetting `become: yes`** - Tasks that need root will fail
4. **Not using handlers** - Inefficient service restarts
5. **Hardcoding values** - Use variables for flexibility
6. **No comments** - Future you will be confused
7. **Over-complicating** - Simple playbooks are maintainable playbooks

## Learning Path for Day 6

**Morning (1 hour):**
1. Read this document
2. Review YAML syntax
3. Look at example playbooks online

**Implementation (2-3 hours):**
1. Create inventory file for your 3 VMs
2. Test connectivity with `ansible all -m ping`
3. Write playbook for base system setup
4. Run with --check, then apply
5. Write playbook for user creation
6. Document why you chose Ansible for these tasks

**Practice (1 hour):**
1. Try ad-hoc commands
2. Experiment with different modules
3. Break something and fix it
4. Run playbooks multiple times (idempotency test)

## Resources

- **Official docs:** https://docs.ansible.com/
- **Ansible for DevOps** (book) - Jeff Geerling
- **Module index:** https://docs.ansible.com/ansible/latest/collections/
- **Best practices:** https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html

## Knowledge Check

Before Day 6, you should be able to:
- [ ] Explain what idempotency means
- [ ] Write a basic inventory file
- [ ] Create a simple playbook with 3-4 tasks
- [ ] Use at least 5 different modules
- [ ] Explain when to use Ansible vs. shell scripts
- [ ] Understand what handlers do and when to use them
- [ ] Run a playbook with --check before applying

## Next Steps

1. Read this document fully
2. Review YAML syntax if unfamiliar
3. When you reach Day 6, create your inventory
4. Write your first playbook
5. Document what you learned in logs/day6.md
