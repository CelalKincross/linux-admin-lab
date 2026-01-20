# HPC Extension — Day 3: Containers with Apptainer

**Date**: 2026-01-20
**Objective**: Implement HPC-style containers using Apptainer integrated with Slurm job scheduling.

## Why Apptainer (Not Docker) in HPC

> "Apptainer is preferred in HPC because it runs without a daemon, does not require root, integrates cleanly with shared filesystems, and works safely with Slurm."

| Feature | Apptainer | Docker |
|---------|-----------|--------|
| **Primary Goal** | Scientific Computing / HPC | DevOps / Microservices |
| **Security Model** | Unprivileged (user stays user) | Privileged (root daemon, escape risk) |
| **Image Format** | Single file (.sif), NFS-friendly | Layers in /var/lib/docker |
| **Shared Storage** | NFS-friendly by default | Host-centric, complex mapping |
| **Hardware Access** | Direct GPU/Infiniband access | Requires --gpus flags, extra setup |
| **Integration** | Auto-mounts home & cwd | Isolated by default |

---

## Phase 3.1 — Apptainer Installation ✅

### Installation (on lab-compute)

Apptainer is not in standard Ubuntu repos — requires PPA:

```bash
# Add official Apptainer repository
sudo add-apt-repository -y ppa:apptainer/ppa

# Update and install
sudo apt update
sudo apt install -y apptainer

# Verify
apptainer --version
```

**Why PPA required:** Apptainer is specialized HPC software. The developers maintain their own repository to ensure latest versions with security patches for cluster environments.

### Build Container Image

```bash
# Create images directory
mkdir -p /research/images

# Build SIF from Docker Hub
apptainer build /research/images/ubuntu_22.04.sif docker://ubuntu:22.04
```

**Result:** 27MB single-file container image on shared storage.

---

## Phase 3.2 — Slurm Integration ✅

### Test Script

```bash
# /research/slurm/my_test_script.sh
#!/bin/bash
echo "--- Container Report ---"
hostname
id
date
echo "--- End Report ---"
```

### Batch Job Script

```bash
#!/bin/bash
#SBATCH --job-name=apptainer-test
#SBATCH --output=/research/slurm/appt-%x-%j.out
#SBATCH --chdir=/research/slurm

apptainer exec --bind /research:/research \
  /research/images/ubuntu_22.04.sif \
  /research/slurm/my_test_script.sh
```

### Job Submission

```bash
sbatch apptainer-script.sbatch
# Submitted batch job 16
```

### Verification

```bash
squeue
#  JOBID PARTITION  NAME      USER ST  TIME  NODES NODELIST
#     16     debug apptainer yanglee  R  0:14  1     lab-compute

cat appt-apptainer-test-16.out
# --- Container Report ---
# lab-compute
# uid=1000(yanglee) gid=1000(yanglee) groups=1000(yanglee),65534(nogroup)
# Tue Jan 20 18:38:30 CST 2026
# --- End Report ---
```

---

## Phase 3.3 — Shared Storage Validation ✅

```bash
# Verify /research visible inside container
apptainer exec --bind /research:/research \
  /research/images/ubuntu_22.04.sif \
  ls -lah /research

# Output shows all shared files with correct permissions
drwxrwsr-x 5 nobody  nogroup 4.0K Jan 20 18:03 .
-rw-r--r-- 1 nobody  nogroup    0 Jan  4 20:04 alice-file
drwxrwsr-x 2 nobody  nogroup 4.0K Jan 20 18:13 images
drwxrws--- 2 nobody  nogroup 4.0K Jan  3 20:56 project1
drwxrwsr-x 2 nobody  nogroup 4.0K Jan 20 18:38 slurm
```

**Key observation:** Files appear as `nobody:nogroup` inside container due to user namespace mapping, but access permissions are enforced correctly.

---

## Troubleshooting

### Issue: Node in DOWN state after slurmd restart

```bash
sinfo
# debug*  up  5:00  1  down lab-compute
```

**Fix:**
```bash
sudo systemctl restart slurmd
sudo scontrol update NodeName=lab-compute State=Resume
sinfo
# debug*  up  5:00  1  idle lab-compute
```

### Issue: Typo in --bind path

```
FATAL: mount source /resesarch doesn't exist
```

**Fix:** Correct spelling: `--bind /research:/research`

### Issue: PMIx warnings in slurmd

```
error: MPI: Cannot create context for mpi/pmix_v5
```

**Explanation:** Slurm compiled with PMIx support but PMIx not installed. Non-blocking for non-MPI workloads — expected in lab environments.

---

## Key Takeaways

1. **Apptainer is rootless** — User inside container = user on host (no privilege escalation)

2. **Single-file images (.sif)** — Easy to store on NFS, copy, share, version control

3. **`--bind` for explicit mounts** — While Apptainer auto-mounts home/cwd, shared directories like `/research` need explicit binding

4. **Scheduler-controlled execution** — Containers run via `sbatch`, not interactively on compute nodes

5. **User context preserved** — `id` inside container shows job user, not root

---

## Interview Talking Points

> "I implemented Apptainer container execution on our HPC compute nodes, integrated with Slurm for scheduler-controlled workloads."

> "I validated shared filesystem visibility by binding /research into containers and verifying access to project data."

> "I chose Apptainer over Docker because HPC environments require rootless operation, NFS compatibility, and no persistent daemon."

---

## Phase 3 Complete ✅

| Component | Location | Status |
|-----------|----------|--------|
| Apptainer | lab-compute | Installed via PPA |
| Container image | /research/images/ubuntu_22.04.sif | 27MB SIF |
| Slurm integration | sbatch + apptainer exec | Working |
| Shared storage | --bind /research:/research | Validated |
