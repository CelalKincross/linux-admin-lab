# Day 3 — SSH Access Control & Hardening

## Objective

Establish secure, role-based SSH access for a research computing environment by:

* Restricting administrative nodes to admins only
* Enforcing SSH key-based authentication
* Disabling password and PAM-based authentication on control-plane systems
* Verifying effective configuration, not just file contents

This mirrors real-world university and research lab practices.

---

## Lab Context

**Nodes involved:**

* `lab-admin` — control-plane / administrative node
* `lab-compute` — researcher-facing compute node

**Policy goal:**

* Admins may SSH into `lab-admin` (keys only)
* Researchers must not access `lab-admin`
* Researchers may SSH into `lab-compute`

---

## SSH Configuration Files (lab-admin)

SSH on Ubuntu 24.04 uses modular configuration via `sshd_config.d`.

```text
/etc/ssh/sshd_config.d/
├── 50-cloud-init.conf        # Ubuntu / cloud-init defaults
├── 99-hardening.conf         # Authentication method hardening
└── 100-auth-policy.conf      # Enforced admin-only policy
```

### 99-hardening.conf

Purpose: Define which authentication mechanisms are *allowed*.

```text
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
```

### 100-auth-policy.conf

Purpose: Enforce authentication *policy* and override distro defaults.

```text
UsePAM no

Match all
  PasswordAuthentication no
```

Separation of concerns is intentional:

* Hardening = posture
* Auth policy = enforcement

---

## SSH Access Restrictions

### Group-based SSH access

Configured in `/etc/ssh/sshd_config`:

```text
AllowGroups sudo
```

Effect:

* Only users in the `sudo` group may SSH into `lab-admin`
* Researchers are blocked at the authentication boundary

---

## SSH Key Authentication

### Key generation (admin workstation)

```bash
ssh-keygen -t ed25519 -C "admin@lab"
```

### Key installation

```bash
ssh-copy-id admin@lab-admin
```

### Verification

```bash
ssh -v admin@lab-admin
```

Expected:

```text
Authentication succeeded (publickey)
```

---

## Debugging & Verification (Critical)

### Syntax validation

```bash
sudo sshd -t
```

### Effective configuration (authoritative)

```bash
sudo sshd -T | egrep -i 'passwordauthentication|kbdinteractiveauthentication|challengeresponseauthentication|usepam'
```

Final expected state:

```text
passwordauthentication no
kbdinteractiveauthentication no
usepam no
```

### Forced password test (from admin workstation)

```bash
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no admin@lab-admin
```

Expected:

```text
Permission denied (publickey).
```

---

## Key Lessons Learned

* SSH configuration is layered and order-dependent
* Included config fragments can override defaults
* PAM can re-enable password prompts unless explicitly disabled
* `sshd -T` is the only reliable way to confirm effective policy
* `Match all` is required for final enforcement on Ubuntu

---

## References — Day 3

### OpenSSH

* sshd_config manual: [https://man.openbsd.org/sshd_config](https://man.openbsd.org/sshd_config)
* ssh manual: [https://man.openbsd.org/ssh](https://man.openbsd.org/ssh)
* ssh-keygen: [https://man.openbsd.org/ssh-keygen](https://man.openbsd.org/ssh-keygen)
* ssh-copy-id: [https://man.openbsd.org/ssh-copy-id](https://man.openbsd.org/ssh-copy-id)

### systemd

* systemctl: [https://www.freedesktop.org/software/systemd/man/systemctl.html](https://www.freedesktop.org/software/systemd/man/systemctl.html)
* systemd units: [https://www.freedesktop.org/software/systemd/man/systemd.unit.html](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)

### Ubuntu

* SSH service documentation: [https://ubuntu.com/server/docs/service-ssh](https://ubuntu.com/server/docs/service-ssh)
* cloud-init SSH behavior: [https://cloudinit.readthedocs.io/](https://cloudinit.readthedocs.io/)

---

## Status

✅ Day 3 complete — SSH access hardened successfully
