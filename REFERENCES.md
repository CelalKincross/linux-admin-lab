# Technical References

This document provides authoritative documentation links for all tools, commands, and concepts used throughout this project. References are organized by day for easy navigation.

---

## Day 1 — Foundation & Environment Setup

### Linux Basics

- **hostnamectl**: [https://man7.org/linux/man-pages/man1/hostnamectl.1.html](https://man7.org/linux/man-pages/man1/hostnamectl.1.html)
  Set or query system hostname and related settings

- **ip**: [https://man7.org/linux/man-pages/man8/ip.8.html](https://man7.org/linux/man-pages/man8/ip.8.html)
  Show/manipulate routing, network devices, interfaces

- **uname**: [https://man7.org/linux/man-pages/man1/uname.1.html](https://man7.org/linux/man-pages/man1/uname.1.html)
  Print system information

### SSH Basics

- **ssh**: [https://man.openbsd.org/ssh](https://man.openbsd.org/ssh)
  OpenSSH remote login client

- **known_hosts**: [https://man.openbsd.org/ssh_config#known_hosts](https://man.openbsd.org/ssh_config#known_hosts)
  SSH host key verification and storage

### Ubuntu Server

- **Ubuntu Server Guide**: [https://ubuntu.com/server/docs](https://ubuntu.com/server/docs)
  Official Ubuntu Server documentation

- **Netplan networking**: [https://netplan.readthedocs.io/](https://netplan.readthedocs.io/)
  Ubuntu's network configuration abstraction

---

## Day 2 — Users, Groups & Permissions

### User & Group Management

- **adduser**: [https://man7.org/linux/man-pages/man8/adduser.8.html](https://man7.org/linux/man-pages/man8/adduser.8.html)
  High-level user creation (Debian/Ubuntu)

- **useradd**: [https://man7.org/linux/man-pages/man8/useradd.8.html](https://man7.org/linux/man-pages/man8/useradd.8.html)
  Low-level user creation command

- **groupadd**: [https://man7.org/linux/man-pages/man8/groupadd.8.html](https://man7.org/linux/man-pages/man8/groupadd.8.html)
  Create a new group

- **usermod**: [https://man7.org/linux/man-pages/man8/usermod.8.html](https://man7.org/linux/man-pages/man8/usermod.8.html)
  Modify user account properties

- **getent**: [https://man7.org/linux/man-pages/man1/getent.1.html](https://man7.org/linux/man-pages/man1/getent.1.html)
  Query administrative databases (passwd, group, etc.)

### File Permissions

- **chmod**: [https://man7.org/linux/man-pages/man1/chmod.1.html](https://man7.org/linux/man-pages/man1/chmod.1.html)
  Change file mode bits (permissions)

- **chown**: [https://man7.org/linux/man-pages/man1/chown.1.html](https://man7.org/linux/man-pages/man1/chown.1.html)
  Change file owner and group

- **umask**: [https://man7.org/linux/man-pages/man2/umask.2.html](https://man7.org/linux/man-pages/man2/umask.2.html)
  Set file mode creation mask

### Advanced Permission Concepts

- **setgid directory bit**: [https://man7.org/linux/man-pages/man1/chmod.1.html#SETUID,_SETGID,_AND_STICKY_BITS](https://man7.org/linux/man-pages/man1/chmod.1.html#SETUID,_SETGID,_AND_STICKY_BITS)
  Special permission bits for group inheritance and restricted deletion

---

## Day 3 — SSH Access Control & Hardening

### OpenSSH

- **sshd_config**: [https://man.openbsd.org/sshd_config](https://man.openbsd.org/sshd_config)
  OpenSSH daemon configuration file

- **ssh**: [https://man.openbsd.org/ssh](https://man.openbsd.org/ssh)
  OpenSSH remote login client

- **ssh-keygen**: [https://man.openbsd.org/ssh-keygen](https://man.openbsd.org/ssh-keygen)
  Authentication key generation and management

- **ssh-copy-id**: [https://man.openbsd.org/ssh-copy-id](https://man.openbsd.org/ssh-copy-id)
  Install SSH key on remote server

### systemd Service Management

- **systemctl**: [https://www.freedesktop.org/software/systemd/man/systemctl.html](https://www.freedesktop.org/software/systemd/man/systemctl.html)
  Control systemd system and service manager

- **systemd.unit**: [https://www.freedesktop.org/software/systemd/man/systemd.unit.html](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)
  systemd unit configuration files

### Ubuntu-Specific SSH

- **SSH service documentation**: [https://ubuntu.com/server/docs/service-ssh](https://ubuntu.com/server/docs/service-ssh)
  Ubuntu's SSH service setup and configuration

- **cloud-init SSH behavior**: [https://cloudinit.readthedocs.io/](https://cloudinit.readthedocs.io/)
  Cloud instance initialization (affects default SSH config)

---

## Day 4 — Shared Storage with NFS

### NFS (Network File System)

- **exports**: [https://man7.org/linux/man-pages/man5/exports.5.html](https://man7.org/linux/man-pages/man5/exports.5.html)
  NFS server export table configuration

- **nfs**: [https://man7.org/linux/man-pages/man5/nfs.5.html](https://man7.org/linux/man-pages/man5/nfs.5.html)
  NFS filesystem options and behavior

- **nfs**: 
https://tldp.org/HOWTO/NFS-HOWTO/server.html


- **exportfs**: [https://man7.org/linux/man-pages/man8/exportfs.8.html](https://man7.org/linux/man-pages/man8/exportfs.8.html)
  Maintain table of exported NFS filesystems

### Mounting & Filesystem Management

- **mount**: [https://man7.org/linux/man-pages/man8/mount.8.html](https://man7.org/linux/man-pages/man8/mount.8.html)
  Mount a filesystem

- **umount**: [https://man7.org/linux/man-pages/man8/umount.8.html](https://man7.org/linux/man-pages/man8/umount.8.html)
  Unmount filesystems

- **fstab**: [https://man7.org/linux/man-pages/man5/fstab.5.html](https://man7.org/linux/man-pages/man5/fstab.5.html)
  Static filesystem mount configuration

- **systemd.mount**: [https://www.freedesktop.org/software/systemd/man/systemd.mount.html](https://www.freedesktop.org/software/systemd/man/systemd.mount.html)
  systemd mount unit configuration

- **systemd.automount**: [https://www.freedesktop.org/software/systemd/man/systemd.automount.html](https://www.freedesktop.org/software/systemd/man/systemd.automount.html)
  systemd automount unit configuration

### Network Services

- **rpcinfo**: [https://man7.org/linux/man-pages/man8/rpcinfo.8.html](https://man7.org/linux/man-pages/man8/rpcinfo.8.html)
  Report RPC information (for NFS diagnostics)

### Ubuntu NFS

- **Ubuntu NFS Guide**: [https://ubuntu.com/server/docs/service-nfs](https://ubuntu.com/server/docs/service-nfs)
  Official Ubuntu Server NFS documentation

---

## Day 5 — systemd Operations & Backup Automation

### systemd Service Management

- **systemd.service**: [https://www.freedesktop.org/software/systemd/man/systemd.service.html](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
  Service unit configuration

- **systemd.timer**: [https://www.freedesktop.org/software/systemd/man/systemd.timer.html](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
  Timer unit configuration for scheduled tasks

- **systemctl**: [https://www.freedesktop.org/software/systemd/man/systemctl.html](https://www.freedesktop.org/software/systemd/man/systemctl.html)
  Control systemd system and service manager (also referenced in Day 3)

### Logging & Monitoring

- **journalctl**: [https://man7.org/linux/man-pages/man1/journalctl.1.html](https://man7.org/linux/man-pages/man1/journalctl.1.html)
  Query systemd journal

- **logger**: [https://man7.org/linux/man-pages/man1/logger.1.html](https://man7.org/linux/man-pages/man1/logger.1.html)
  Enter messages into system log

### Backup & File Synchronization

- **rsync**: [https://man7.org/linux/man-pages/man1/rsync.1.html](https://man7.org/linux/man-pages/man1/rsync.1.html)
  Fast, versatile file copying tool

- **rsync --link-dest**: [https://download.samba.org/pub/rsync/rsync.1#opt--link-dest](https://download.samba.org/pub/rsync/rsync.1#opt--link-dest)
  Hardlink to files in DIR when unchanged (for snapshot-style backups)

### Filesystem Tools

- **mountpoint**: [https://man7.org/linux/man-pages/man1/mountpoint.1.html](https://man7.org/linux/man-pages/man1/mountpoint.1.html)
  Check if directory is a mount point

---

## Day 6 — Ansible Configuration Management

### Ansible Core

- **Ansible Documentation**: [https://docs.ansible.com/ansible/latest/](https://docs.ansible.com/ansible/latest/)
  Official Ansible documentation

- **Getting Started Guide**: [https://docs.ansible.com/ansible/latest/getting_started/](https://docs.ansible.com/ansible/latest/getting_started/)
  Introduction to Ansible concepts and first playbook

- **ansible command**: [https://docs.ansible.com/ansible/latest/cli/ansible.html](https://docs.ansible.com/ansible/latest/cli/ansible.html)
  CLI tool for ad-hoc task execution

- **ansible-playbook command**: [https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html)
  Runs Ansible playbooks

### Inventory

- **Inventory Guide**: [https://docs.ansible.com/ansible/latest/inventory_guide/index.html](https://docs.ansible.com/ansible/latest/inventory_guide/index.html)
  How to build and use inventory

- **Inventory Plugins**: [https://docs.ansible.com/ansible/latest/plugins/inventory.html](https://docs.ansible.com/ansible/latest/plugins/inventory.html)
  Dynamic inventory sources

### Playbooks

- **Playbook Guide**: [https://docs.ansible.com/ansible/latest/playbook_guide/index.html](https://docs.ansible.com/ansible/latest/playbook_guide/index.html)
  Complete guide to Ansible playbooks

- **YAML Syntax**: [https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)
  YAML syntax for Ansible

- **Playbook Best Practices**: [https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
  Tips and best practices

### Modules

- **Module Index**: [https://docs.ansible.com/ansible/latest/collections/index_module.html](https://docs.ansible.com/ansible/latest/collections/index_module.html)
  Complete list of Ansible modules

- **ansible.builtin collection**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)
  Core modules included with Ansible

- **apt module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
  Manages apt packages

- **file module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)
  Manage files and file properties

- **copy module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
  Copy files to remote locations

- **service module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html)
  Manage services

- **systemd module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html)
  Manage systemd units

- **group module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html)
  Add or remove groups

- **command module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html)
  Execute commands on targets (no shell features)

- **shell module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)
  Execute shell commands on targets

### Configuration

- **Ansible Configuration**: [https://docs.ansible.com/ansible/latest/reference_appendices/config.html](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)
  ansible.cfg configuration file options

- **Privilege Escalation**: [https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html)
  Understanding privilege escalation (become)

### Concepts

- **Idempotency**: [https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html#term-Idempotency](https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html#term-Idempotency)
  Understanding idempotent operations

- **Check Mode (Dry Run)**: [https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html)
  Running playbooks without making changes

---

## Day 7 — Off-Host Backup & Disaster Recovery

### rsync Advanced Features

- **rsync --link-dest**: [https://download.samba.org/pub/rsync/rsync.1#opt--link-dest](https://download.samba.org/pub/rsync/rsync.1#opt--link-dest)
  Hardlink to files in DIR when unchanged (for snapshot-style backups) - also referenced in Day 5

- **rsync**: [https://man7.org/linux/man-pages/man1/rsync.1.html](https://man7.org/linux/man-pages/man1/rsync.1.html)
  Fast, versatile file copying tool - also referenced in Day 5

### SSH for Automation

- **ssh-keygen**: [https://man.openbsd.org/ssh-keygen](https://man.openbsd.org/ssh-keygen)
  Authentication key generation and management - also referenced in Day 3

- **authorized_keys**: [https://man.openbsd.org/sshd#AUTHORIZED_KEYS_FILE_FORMAT](https://man.openbsd.org/sshd#AUTHORIZED_KEYS_FILE_FORMAT)
  SSH authorized keys file format and options

- **SSH Best Practices**: [https://www.ssh.com/academy/ssh/public-key-authentication](https://www.ssh.com/academy/ssh/public-key-authentication)
  Public key authentication for automation

### sudo Configuration

- **sudoers**: [https://man7.org/linux/man-pages/man5/sudoers.5.html](https://man7.org/linux/man-pages/man5/sudoers.5.html)
  sudo configuration file format

- **visudo**: [https://man7.org/linux/man-pages/man8/visudo.8.html](https://man7.org/linux/man-pages/man8/visudo.8.html)
  Edit sudoers file safely

- **sudo NOPASSWD security**: [https://www.sudo.ws/security/advisories/](https://www.sudo.ws/security/advisories/)
  Understanding sudo security implications

### systemd Timer Configuration

- **systemd.timer**: [https://www.freedesktop.org/software/systemd/man/systemd.timer.html](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
  Timer unit configuration - also referenced in Day 5

- **OnCalendar syntax**: [https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)
  Calendar event expressions for timer scheduling

- **systemd-analyze calendar**: [https://www.freedesktop.org/software/systemd/man/systemd-analyze.html](https://www.freedesktop.org/software/systemd/man/systemd-analyze.html)
  Validate and test timer calendar expressions

### Backup Best Practices

- **Backup Strategies**: [https://en.wikipedia.org/wiki/Backup](https://en.wikipedia.org/wiki/Backup)
  Overview of backup strategies and architectures

- **3-2-1 Backup Rule**: [https://www.backblaze.com/blog/the-3-2-1-backup-strategy/](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/)
  Industry standard backup approach

- **Pull vs Push Backups**: [https://borgbackup.readthedocs.io/en/stable/deployment.html](https://borgbackup.readthedocs.io/en/stable/deployment.html)
  Security considerations for backup architecture

---

## General Linux Resources

### Online Man Pages

- **man7.org**: [https://man7.org/linux/man-pages/](https://man7.org/linux/man-pages/)
  Comprehensive Linux man-pages project

- **OpenBSD Man Pages**: [https://man.openbsd.org/](https://man.openbsd.org/)
  OpenSSH and other OpenBSD project documentation

### Research Computing Best Practices

- **Access for Researchers (General knowledge, HPC)**:
https://access-ci.org/


- **HPC Systems Professionals**: [https://hpc-sysadmins.org/](https://hpc-sysadmins.org/)
  Community resources for research computing system administrators

---

## HPC Extension — Slurm Job Scheduling

### Slurm Workload Manager

- **Slurm Documentation**: [https://slurm.schedmd.com/documentation.html](https://slurm.schedmd.com/documentation.html)
  Official Slurm documentation and administration guide

- **slurm.conf**: [https://slurm.schedmd.com/slurm.conf.html](https://slurm.schedmd.com/slurm.conf.html)
  Main configuration file reference

- **slurmctld**: [https://slurm.schedmd.com/slurmctld.html](https://slurm.schedmd.com/slurmctld.html)
  Slurm controller daemon

- **slurmd**: [https://slurm.schedmd.com/slurmd.html](https://slurm.schedmd.com/slurmd.html)
  Slurm compute node daemon

- **slurmdbd**: [https://slurm.schedmd.com/slurmdbd.html](https://slurm.schedmd.com/slurmdbd.html)
  Slurm database daemon for accounting

- **sacctmgr**: [https://slurm.schedmd.com/sacctmgr.html](https://slurm.schedmd.com/sacctmgr.html)
  Account management for Slurm

### Slurm Commands

- **sbatch**: [https://slurm.schedmd.com/sbatch.html](https://slurm.schedmd.com/sbatch.html)
  Submit batch jobs

- **squeue**: [https://slurm.schedmd.com/squeue.html](https://slurm.schedmd.com/squeue.html)
  View job queue

- **sinfo**: [https://slurm.schedmd.com/sinfo.html](https://slurm.schedmd.com/sinfo.html)
  View cluster/partition status

- **scontrol**: [https://slurm.schedmd.com/scontrol.html](https://slurm.schedmd.com/scontrol.html)
  Administrative control commands

- **sacct**: [https://slurm.schedmd.com/sacct.html](https://slurm.schedmd.com/sacct.html)
  Job accounting information

### MUNGE Authentication

- **MUNGE**: [https://dun.github.io/munge/](https://dun.github.io/munge/)
  MUNGE Uid 'N' Gid Emporium - authentication service for HPC

- **MUNGE Installation Guide**: [https://github.com/dun/munge/wiki/Installation-Guide](https://github.com/dun/munge/wiki/Installation-Guide)
  Installing and configuring MUNGE

---

## HPC Extension — Monitoring & Observability

### Prometheus

- **Prometheus Documentation**: [https://prometheus.io/docs/](https://prometheus.io/docs/)
  Official Prometheus documentation

- **Prometheus Configuration**: [https://prometheus.io/docs/prometheus/latest/configuration/configuration/](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
  prometheus.yml configuration reference

- **Alerting Rules**: [https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
  Defining alerting rules in Prometheus

- **PromQL**: [https://prometheus.io/docs/prometheus/latest/querying/basics/](https://prometheus.io/docs/prometheus/latest/querying/basics/)
  Prometheus Query Language basics

### Node Exporter

- **Node Exporter**: [https://github.com/prometheus/node_exporter](https://github.com/prometheus/node_exporter)
  Prometheus exporter for hardware and OS metrics

- **Node Exporter Metrics**: [https://prometheus.io/docs/guides/node-exporter/](https://prometheus.io/docs/guides/node-exporter/)
  Guide to using Node Exporter

### Grafana

- **Grafana Documentation**: [https://grafana.com/docs/grafana/latest/](https://grafana.com/docs/grafana/latest/)
  Official Grafana documentation

- **Grafana Dashboards**: [https://grafana.com/grafana/dashboards/](https://grafana.com/grafana/dashboards/)
  Pre-built dashboard library (Node Exporter Full: ID 1860)

- **Prometheus Data Source**: [https://grafana.com/docs/grafana/latest/datasources/prometheus/](https://grafana.com/docs/grafana/latest/datasources/prometheus/)
  Configuring Prometheus as Grafana data source

---

## HPC Extension — Containers (Apptainer)

### Apptainer (formerly Singularity)

- **Apptainer Documentation**: [https://apptainer.org/docs/user/latest/](https://apptainer.org/docs/user/latest/)
  Official Apptainer user guide

- **Apptainer Quick Start**: [https://apptainer.org/docs/user/latest/quick_start.html](https://apptainer.org/docs/user/latest/quick_start.html)
  Getting started with Apptainer

- **Apptainer Build**: [https://apptainer.org/docs/user/latest/build_a_container.html](https://apptainer.org/docs/user/latest/build_a_container.html)
  Building container images (SIF format)

- **Apptainer Bind Mounts**: [https://apptainer.org/docs/user/latest/bind_paths_and_mounts.html](https://apptainer.org/docs/user/latest/bind_paths_and_mounts.html)
  Mounting host directories into containers

### Apptainer + Slurm Integration

- **Running Apptainer with Slurm**: [https://apptainer.org/docs/user/latest/running_services.html](https://apptainer.org/docs/user/latest/running_services.html)
  Integrating containers with job schedulers

- **HPC Container Best Practices**: [https://hpc-containers.github.io/](https://hpc-containers.github.io/)
  Community best practices for containers in HPC

### Why Apptainer over Docker in HPC

- **Apptainer Security Model**: [https://apptainer.org/docs/user/latest/security.html](https://apptainer.org/docs/user/latest/security.html)
  Understanding rootless container execution

---

*Last updated: 2026-01-20*
