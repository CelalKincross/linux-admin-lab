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

---

## Phase 1.3 — Job Execution, Accounting & Failure Analysis ✅

### Step 1: Node State Debugging

**Symptom:** `sinfo` showed node in `down*` state:
```
debug* up 5:00 1 down* lab-compute
```

**Resolution:**
```bash
# On lab-compute
sudo systemctl restart slurmd

# On lab-admin - clear node state
scontrol update nodename=lab-compute state=idle

# Verify
scontrol show node lab-compute
```

**Result:**
```
State=IDLE
CPUTot=2
RealMemory=1900
```

### Step 2: Slurm User & MUNGE Verification

**Verified consistent Slurm UID across nodes:**
```bash
getent passwd slurm
# Result: uid=64030(slurm) gid=64030(slurm)
```

**Verified cross-node MUNGE authentication:**
```bash
munge -n | ssh lab-compute unmunge
# Result: STATUS: Success (0)
```

### Step 3: Accounting Setup (slurmdbd + MariaDB)

**Added to `slurm.conf`:**
```ini
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=lab-admin
AccountingStoragePort=6819
AccountingStorageEnforce=associations
```

**Configured slurmdbd with MariaDB backend, then registered cluster/accounts/users:**
```bash
sacctmgr add cluster labcluster
sacctmgr add account researchers cluster=labcluster
sacctmgr add user yanglee cluster=labcluster account=researchers

# Verify
sacctmgr show associations
```

### Step 4: Job Failure Investigation (Critical Learning)

**Symptom:**
- Jobs submitted successfully but immediately completed
- No output file created
- `WTERMSIG 53` reported in controller log

**Controller log:**
```
_job_complete: JobId=X WTERMSIG 53
```

**Root cause (from slurmd logs on lab-compute):**
```
Could not open stdout file /research/slurm/test-fail-8.out: Permission denied
Slurmd could not connect IO
```

**Explanation:**
1. Slurm opens stdout/stderr **on the compute node**
2. Files are created as the submitting user
3. Output directory lacked write permission for job user at execution time
4. Job failed **before** user payload execution → SIGTRAP (signal 53)

### Step 5: Resolution

**Fix:** Ensure job runs from writable directory:
```bash
#SBATCH --chdir=/research/slurm
```

Or submit job while in a writable directory.

**Result:** Jobs execute successfully, output files created, normal completion.

### Notes: PMIx Warnings

**Observed:**
```
MPI: Cannot create context for mpi/pmix_v5
```

**Explanation:** Slurm compiled with PMIx support but PMIx not installed. Non-blocking for non-MPI jobs — expected in lab environments.

---

## Key Takeaways (Interview-Grade)

1. **Job failures can occur before execution** — I/O setup (stdout/stderr) happens first; permission issues kill jobs immediately

2. **Accounting enforcement is strict** — Jobs rejected unless cluster, accounts, and users are fully registered in slurmdbd

3. **Stdout/stderr is a compute-node concern** — The compute node creates output files, not the controller

4. **Log-driven debugging is essential** — Check `slurmd`, `slurmctld`, and `slurmdbd` logs systematically

5. **Small clusters exhibit real production failures** — Permission issues, node state problems, and accounting errors are the same at any scale

---

## Phase 1.4 — Failure Injection & Recovery ✅

**Goal:** Validate Slurm's behavior under failure — not just successful execution.

### Scenario A: Compute Node Daemon Interruption

```bash
# Simulate node failure
sudo systemctl stop slurmd

# Observe
sinfo  # Node shows DOWN

# Recover
sudo systemctl start slurmd
```

**Result:** Node returns to IDLE, scheduler resumes normal operation.

### Scenario B: Job Interruption During Execution

Interrupted `slurmd` while a job was running. Observed state transitions:

| State | Meaning |
|-------|---------|
| `CG` (Completing) | Slurm detected node loss, attempting cleanup |
| `PD` (BeginTime) | Job rescheduled, waiting for node stability |
| `R` (Running) | Job re-executed after node recovery |

**Key insight:** Slurm doesn't blindly discard jobs — it defers re-execution until the node is stable to prevent double execution and accounting inconsistencies.

### Scenario C: Configuration Mismatch

**Symptom:**
```
Node lab-compute appears to have a different slurm.conf
```

**Diagnosis:**
```bash
sha256sum /etc/slurm/slurm.conf  # Compare on both nodes
```

**Fix:** Sync config, restart `slurmctld` and `slurmd`.

### Operational Observations

These are support engineer insights:

1. **Slurm does not "fix" configuration problems** — Admin intervention required
2. **Node health ≠ job success** — Services can be "running" while jobs fail
3. **Many failures occur after scheduling** — I/O setup, permissions, execution context
4. **CG state is cleanup, not running** — Important distinction for troubleshooting

---

## Phase 1 Complete ✅

**Interview one-liner:**

> "I intentionally validated Slurm's behavior under failure by stopping node daemons, observing state transitions, and recovering from configuration and job-level errors. The goal was to understand operational recovery, not just successful scheduling."
