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

## Future Days

References for Days 6-7 will be added as those sections are completed:

- **Day 6**: Ansible & Configuration Management
- **Day 7**: Documentation & portfolio finalization

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

*Last updated: 2026-01-04*
