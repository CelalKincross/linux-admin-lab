# Permissions & Access Control

**Last updated:** 2026-01-02
**System:** lab-admin

## Overview

This document describes the multi-user permission model implemented on the lab-admin server. The model supports collaborative research workflows while maintaining project-level data isolation.

## User & Group Model

### Users

Three researcher accounts are configured:
- `alice` - Researcher
- `bob` - Researcher
- `carol` - Researcher

Additionally, the `admin` account manages system administration and does not participate in research collaboration groups.

### Groups

**General Collaboration:**
- **Group:** `researchers`
- **Members:** alice, bob, carol
- **Purpose:** Lab-wide collaboration on shared research data

**Project-Specific Access:**
- **Group:** `project1`
- **Members:** alice, bob (carol excluded)
- **Purpose:** Restricted access to Project 1 data and results

## Directory Structure

```
/research/                      → General research storage
├── shared files                → Accessible by all researchers
└── project1/                   → Restricted to project1 group members
    └── project files           → alice and bob only
```

### Directory Permissions

**General Research Directory:**
```bash
/research
Owner: root
Group: researchers
Permissions: drwxrwsr-x (2775)
```

The `s` (setgid bit) in group permissions ensures all files created in this directory automatically inherit the `researchers` group, enabling seamless collaboration.

**Project-Specific Directory:**
```bash
/research/project1
Owner: root
Group: project1
Permissions: drwxrws--- (2770)
```

The `0` (no permissions for others) ensures only project1 members can access this directory. Non-members are denied entry entirely.

## Permission Policy Rationale

### Why setgid?

By default, Linux files inherit the creator's primary group. In multi-user environments, this breaks collaboration—Alice creates a file owned by the `alice` group, and Bob cannot edit it even though both are in the `researchers` group.

**The setgid bit solves this:**
- Files created in `/research` inherit the `researchers` group
- Files created in `/research/project1` inherit the `project1` group
- No manual file ownership changes required
- Scales cleanly as new users and files are added

### Why root ownership?

Directories are owned by `root` to:
- Maintain administrative control over infrastructure
- Prevent accidental deletion or permission changes by researchers
- Enforce consistent access policy
- Separate infrastructure management from research workflows

### Admin Separation

The `admin` account is deliberately **not** a member of research groups. This ensures:
- Clear audit trail (files owned by researchers, not admin)
- Prevents accidental admin ownership of research data
- Maintains principle of least privilege

## Access Scenarios

### Scenario 1: General Collaboration

**Alice creates a file in /research:**
```bash
$ touch /research/data.csv
$ ls -l /research/data.csv
-rw-r--r-- 1 alice researchers 0 Jan 2 data.csv
```

**Bob can read and edit Alice's file:**
```bash
$ echo "analysis complete" >> /research/data.csv
# Success - both share the researchers group
```

### Scenario 2: Project Isolation

**Alice creates a project file:**
```bash
$ touch /research/project1/results.txt
$ ls -l /research/project1/results.txt
-rw-r--r-- 1 alice project1 0 Jan 2 results.txt
```

**Bob (project member) can access:**
```bash
$ cat /research/project1/results.txt
# Success - Bob is in project1 group
```

**Carol (not in project1) cannot access:**
```bash
$ cd /research/project1
bash: cd: /research/project1: Permission denied
```

This is correct behavior—Carol should not access Project 1 data.

## Requesting Project Access

To request access to a project-specific directory:

1. Contact the system administrator with:
   - Your username
   - Project identifier (e.g., project1)
   - Justification for access

2. Administrator will verify authorization and add your account to the project group:
   ```bash
   sudo usermod -aG project1 <username>
   ```

3. Log out and back in for group membership to take effect:
   ```bash
   exit
   ssh lab-admin
   groups  # Verify project1 appears in your groups
   ```

## Troubleshooting Common Issues

### Issue: "Permission denied" when accessing /research

**Symptoms:**
```bash
$ cd /research
bash: cd: /research: Permission denied
```

**Cause:** User is not a member of the `researchers` group.

**Resolution:**
```bash
# Check group membership
$ groups
alice users  # 'researchers' is missing

# Contact admin to add you to the group
# After admin adds you, log out and back in
$ exit
$ ssh lab-admin
$ groups
alice users researchers  # Now correct
```

### Issue: Cannot edit collaborator's file

**Symptoms:**
```bash
$ echo "data" >> /research/alice-file.txt
bash: /research/alice-file.txt: Permission denied
```

**Cause:** File does not have group write permissions.

**Resolution:**
Check file permissions:
```bash
$ ls -l /research/alice-file.txt
-rw-r--r-- 1 alice researchers 0 Jan 2 alice-file.txt
          ^^^
          Group has read-only (r--), needs write (rw-)
```

File creator can fix:
```bash
$ chmod g+w /research/alice-file.txt
$ ls -l /research/alice-file.txt
-rw-rw-r-- 1 alice researchers 0 Jan 2 alice-file.txt
          ^^^
          Group can now write
```

**Prevention:** Set default umask to create group-writable files:
```bash
$ umask 002  # Add to ~/.bashrc for persistence
```

### Issue: New files have wrong group ownership

**Symptoms:**
```bash
$ touch /research/myfile.txt
$ ls -l /research/myfile.txt
-rw-r--r-- 1 bob bob 0 Jan 2 myfile.txt
                   ^^^
                   Should be 'researchers', not 'bob'
```

**Cause:** The setgid bit is not set on the `/research` directory.

**Resolution (admin only):**
```bash
$ ls -ld /research
drwxrwxr-x 2 root researchers /research  # Missing 's' in group permissions

$ sudo chmod 2775 /research
$ ls -ld /research
drwxrwsr-x 2 root researchers /research  # 's' now present
              ^
```

New files will now correctly inherit the `researchers` group.

### Issue: Cannot access project directory after being added to group

**Symptoms:**
```bash
$ groups
alice users researchers project1  # project1 is listed

$ cd /research/project1
bash: cd: /research/project1: Permission denied
```

**Cause:** Group membership was added but you haven't logged out and back in.

**Resolution:**
```bash
$ exit
# SSH back into lab-admin
$ groups
alice users researchers project1  # Should work now
$ cd /research/project1
$ pwd
/research/project1  # Success
```

**Why this happens:** Linux applies group membership at login. Changes to `/etc/group` don't affect active sessions.

## Best Practices

### For Researchers

1. **Always work in shared directories:** Files created in `/research` automatically support collaboration
2. **Use group-writable permissions:** Set `umask 002` to make your files editable by collaborators
3. **Don't move files from home directories:** Files created in `~alice` will have wrong group ownership; create them directly in `/research`
4. **Request project access proactively:** If you need access to a project directory, request it early

### For Administrators

1. **Never add admin to research groups:** Maintain separation between infrastructure and research workflows
2. **Always set setgid on collaborative directories:** Use `chmod 2775` for shared spaces
3. **Test access as actual users:** Don't assume permissions work—use `su - alice` to verify
4. **Document permission changes:** Log all group membership and directory permission modifications

## Verification Commands

**Check user group membership:**
```bash
# System-wide view
getent group researchers

# User perspective
su - alice
groups
```

**Inspect directory permissions:**
```bash
# Directory
ls -ld /research

# Files within directory
ls -l /research
```

**Test access as a user:**
```bash
su - alice
cd /research
touch test-file
ls -l test-file  # Verify group ownership
exit
```

## Related Documentation

- **Architecture:** See [architecture.md](../architecture.md) for VM design and roles
- **Daily Logs:** See [logs/day2.md](../logs/day2.md) for implementation details
- **Onboarding:** (Planned for Day 7)

## Questions or Issues?

Contact the system administrator for:
- Access requests
- Permission troubleshooting
- Questions about this permission model
