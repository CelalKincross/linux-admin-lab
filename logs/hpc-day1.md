# HPC Extension — Day 1: Slurm Setup

**Date**: 2026-01-18
**Objective**: Install and configure Slurm job scheduler across lab-admin (controller) and lab-compute (worker)

## Phase 1.1 — Architecture Planning ✅

Reviewed cluster architecture and role assignments:
- **lab-admin** → Slurm controller (slurmctld)
- **lab-compute** → Slurm compute node (slurmd)
- Shared authentication via MUNGE

## Phase 1.2 — Slurm Installation ✅

### Step 1: Package Installation

**On lab-admin (controller):**
```bash
sudo apt update
sudo apt install -y slurmctld slurm-client munge
```

**On lab-compute (worker):**
```bash
sudo apt update
sudo apt install -y slurmd slurm-client munge
```

**Why these packages:**
- `munge` — Handles authentication between nodes (shared-key credential system)
- `slurm-client` — CLI tools (sinfo, squeue, sbatch, etc.)
- `slurmctld` — Controller daemon (only on head node)
- `slurmd` — Compute daemon (only on worker nodes)

### Step 2: MUNGE Configuration

**On lab-admin:**
```bash
sudo systemctl enable munge
sudo systemctl start munge

# Verify MUNGE works locally
munge -n | unmunge
```

**Copy key to compute node:**
```bash
sudo scp /etc/munge/munge.key lab-compute:/etc/munge/munge.key
```

**On lab-compute:**
```bash
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl start munge
```

### Step 3: Slurm Configuration

**Create config directory and file on lab-admin:**
```bash
sudo mkdir -p /etc/slurm
sudo vim /etc/slurm/slurm.conf
```

**Final working `/etc/slurm/slurm.conf`:**
```ini
ClusterName=labcluster
SlurmctldHost=lab-admin

AuthType=auth/munge

StateSaveLocation=/var/lib/slurm/slurmctld
SlurmdSpoolDir=/var/lib/slurm/slurmd

SlurmctldLogFile=/var/log/slurmctld.log
SlurmdLogFile=/var/log/slurmd.log

NodeName=lab-compute CPUs=2 State=UNKNOWN
PartitionName=debug Nodes=lab-compute Default=YES MaxTime=00:05:00 State=UP
```

### Step 4: Sync Config to Compute Node

```bash
sudo scp /etc/slurm/slurm.conf lab-compute:/etc/slurm/slurm.conf
```

⚠️ **Critical**: `slurm.conf` must be byte-for-byte identical on all nodes.

### Step 5: Service Startup

**On lab-admin (controller first):**
```bash
sudo systemctl enable slurmctld
sudo systemctl start slurmctld
sudo systemctl status slurmctld
```

**On lab-compute (worker):**
```bash
sudo systemctl enable slurmd
sudo systemctl start slurmd
sudo systemctl status slurmd
```

### Step 6: Verification

```bash
sinfo    # Check cluster/partition status
squeue   # Check job queue (empty initially)
```

---

## Troubleshooting Notes

### Issue: `MungeKeyFile` is not a valid Slurm directive

**Symptom:**
```
error: _parse_next_key: Parsing error at unrecognized key: MungeKeyFile
fatal: Unable to process configuration file
```

**Root Cause:**
The original guide included `MungeKeyFile=/etc/munge/munge.key` in `slurm.conf`. This is **not a valid Slurm configuration option**.

Slurm does NOT read the Munge key path from its config. Instead:
- MUNGE always uses `/etc/munge/munge.key` by default
- Slurm authenticates via MUNGE implicitly when `AuthType=auth/munge` is set

**Fix:**
Remove the invalid line from `slurm.conf` on both nodes:
```diff
- MungeKeyFile=/etc/munge/munge.key   ❌ INVALID
```

Then restart services in order:
```bash
# On lab-admin
sudo systemctl restart slurmctld

# On lab-compute
sudo systemctl restart slurmd
```

---

## Lessons Learned

1. **MUNGE configuration is implicit** — Slurm uses MUNGE automatically when `AuthType=auth/munge` is set. There's no need (or way) to specify the key path in `slurm.conf`.

2. **Validate config before deploying** — Could use `slurmd -C` on compute nodes to print detected hardware, and check logs immediately after service start.

3. **Start controller before workers** — Always bring up `slurmctld` first, then `slurmd` on compute nodes.

4. **Error messages are precise** — "unrecognized key" tells you exactly what's wrong. Read error messages carefully.
