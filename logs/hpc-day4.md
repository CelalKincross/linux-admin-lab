# HPC Extension — Day 4: Ansible Automation for HPC

**Date**: 2026-01-20
**Objective**: Automate HPC component deployment using Ansible playbooks for reproducible, idempotent configuration management.

## Why Ansible for HPC

> "I use Ansible to ensure HPC components are deployed consistently across nodes. Configuration drift is eliminated, and new nodes can be provisioned identically."

**Benefits:**
- **Idempotent**: Running playbooks multiple times produces same result
- **Agentless**: No software to install on managed nodes (SSH-based)
- **Declarative**: Describe desired state, not procedural steps
- **Auditable**: Playbooks serve as documentation of configuration

---

## Phase 4 Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Ansible Control Node                     │
│                    (macOS workstation)                      │
│                                                            │
│   ansible/                                                 │
│   ├── inventory.ini         # Host groups                  │
│   ├── playbooks/                                           │
│   │   ├── munge.yml         # MUNGE key distribution       │
│   │   ├── slurm.yml         # Slurm config sync            │
│   │   ├── monitoring.yml    # Node exporter state          │
│   │   └── apptainer.yml     # Container runtime            │
│   └── files/                                               │
│       ├── munge.key         # (gitignored - secret)        │
│       └── slurm.conf        # Cluster configuration        │
└────────────────────────────────────────────────────────────┘
            │
            │ SSH
            ▼
┌──────────────────┐     ┌──────────────────┐
│   lab-admin      │     │   lab-compute    │
│   (controller)   │     │   (worker)       │
│                  │     │                  │
│   - slurmctld    │     │   - slurmd       │
│   - slurmdbd     │     │   - node_exporter│
│   - munge        │     │   - munge        │
│                  │     │   - apptainer    │
└──────────────────┘     └──────────────────┘
```

---

## Playbook: MUNGE Key Distribution

**Purpose:** Ensure identical MUNGE key on all Slurm nodes for authentication.

```yaml
# ansible/playbooks/munge.yml
- name: Ensure Munge consistency
  hosts: controller:compute
  become: true

  tasks:
    - name: Deploy munge.key
      copy:
        src: files/munge.key
        dest: /etc/munge/munge.key
        owner: munge
        group: munge
        mode: "0400"
      notify: Restart Munge

  handlers:
    - name: Restart Munge
      service:
        name: munge
        state: restarted
```

**Key points:**
- `mode: "0400"` enforces strict permissions (MUNGE requires this)
- Handler only restarts if key changes (idempotent)
- `files/munge.key` is gitignored (secret material)

---

## Playbook: Slurm Configuration Sync

**Purpose:** Keep `slurm.conf` identical across all nodes (Slurm requirement).

```yaml
# ansible/playbooks/slurm.yml
- name: Sync Slurm configuration
  hosts: controller:compute
  become: true

  tasks:
    - name: Deploy slurm.conf
      copy:
        src: files/slurm.conf
        dest: /etc/slurm/slurm.conf
        owner: slurm
        group: slurm
        mode: "0644"
      notify: Restart Slurm services
```

**Configuration deployed:**
```ini
ClusterName=labcluster
SlurmUser=slurm
SlurmctldHost=lab-admin
AuthType=auth/munge

AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=lab-admin
AccountingStorageEnforce=associations

NodeName=lab-compute CPUs=2 RealMemory=1900 State=IDLE
PartitionName=debug Nodes=lab-compute Default=YES MaxTime=00:05:00 State=UP
```

---

## Playbook: Monitoring (Node Exporter)

**Purpose:** Ensure node_exporter is running on compute nodes.

```yaml
# ansible/playbooks/monitoring.yml
- name: Install node exporter
  hosts: compute
  become: true

  tasks:
    - name: Ensure node_exporter is running
      service:
        name: node_exporter
        state: started
        enabled: true
```

---

## Playbook: Apptainer

**Purpose:** Ensure Apptainer container runtime is installed on compute nodes.

```yaml
# ansible/playbooks/apptainer.yml
- name: Ensure Apptainer installed
  hosts: compute
  become: true

  tasks:
    - name: Install apptainer
      apt:
        name: apptainer
        state: present
```

---

## Inventory Structure

```ini
# ansible/inventory.ini
[admin]
lab-admin

[compute]
lab-compute

[backup]
lab-backup

[all:vars]
ansible_user=yanglee
ansible_python_interpreter=/usr/bin/python3
```

**Note:** For HPC playbooks, use `controller:compute` to target Slurm nodes.

---

## Running Playbooks

```bash
# From ansible directory
cd /Users/yanglee/Desktop/linux-admin-lab/ansible

# Deploy MUNGE key
ansible-playbook playbooks/munge.yml

# Sync Slurm config
ansible-playbook playbooks/slurm.yml

# Ensure monitoring
ansible-playbook playbooks/monitoring.yml

# Ensure Apptainer
ansible-playbook playbooks/apptainer.yml

# Run all HPC playbooks
ansible-playbook playbooks/munge.yml playbooks/slurm.yml playbooks/monitoring.yml playbooks/apptainer.yml
```

---

## Security Considerations

### Secrets Management

| File | Status | Reason |
|------|--------|--------|
| `munge.key` | **Gitignored** | Shared secret for cluster authentication |
| `slurm.conf` | Committed | No secrets, configuration only |

**Best practice:** Never commit secrets to version control. Use Ansible Vault for production environments.

---

## Key Takeaways

1. **Handlers for restarts** — Services only restart when configuration actually changes

2. **Strict permissions matter** — MUNGE requires `0400` on key file; Ansible enforces this

3. **Single source of truth** — `files/slurm.conf` is the authoritative config; playbooks distribute it

4. **Idempotent by design** — Run playbooks repeatedly without side effects

5. **Separation of concerns** — Each playbook handles one component (MUNGE, Slurm, monitoring, containers)

---

## Interview Talking Points

> "I automated HPC component deployment using Ansible playbooks. MUNGE keys and Slurm configuration are distributed idempotently, eliminating configuration drift."

> "Sensitive materials like MUNGE keys are gitignored. In production, I'd use Ansible Vault for secrets management."

> "The playbooks serve as executable documentation — anyone can see exactly how the cluster is configured."

---

## Phase 4 Complete ✅

| Playbook | Target | Purpose |
|----------|--------|---------|
| `munge.yml` | controller + compute | MUNGE key distribution |
| `slurm.yml` | controller + compute | Slurm config sync |
| `monitoring.yml` | compute | Node exporter state |
| `apptainer.yml` | compute | Container runtime |
