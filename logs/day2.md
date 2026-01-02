# Day 2 - Multi-User Administration & Permissions

**Date:** 2026-01-02
**Planned Outcomes:** Implement group-based access control with collaborative file ownership
**Status:** In Progress (Parts 1-4 completed)

## Lab Scope

**Primary work environment:** lab-admin
**Approach:** Manual, intentional implementation (no automation)
**Goal:** Build multi-user collaboration using Linux groups and permissions

## Part 1 - User Model Design

### Design Decisions

**Users:**
- `alice` → researcher
- `bob` → researcher
- `carol` → researcher
- `admin` (existing) → system administrator

**Groups:**
- `researchers` → general lab membership (all researchers)
- `project1` → project-specific access (subset of researchers)

**Rationale:**
This model mirrors real academic research environments where:
- Base collaboration happens at the lab level
- Project-specific work requires additional access boundaries
- Administrative access remains separate from researcher workflows

## Part 2 - User Creation

### Implementation

Created isolated researcher accounts:
```bash
sudo adduser alice
sudo adduser bob
sudo adduser carol
```

**Verification:**
```bash
getent passwd alice bob carol
ls -ld /home/alice /home/bob /home/carol
```

**Test login for each user:**
```bash
su - alice
whoami && pwd && exit
```

### Observations

- Each user created with default home directory (`drwx------`)
- Private primary groups assigned automatically
- Shell and environment configured correctly
- Users start fully isolated (no shared access)

**Key Decision:**
Users were intentionally created without shared access or group memberships. Baseline isolation ensures clean permission layering in subsequent steps.

## Part 3 - Group Creation & Membership

### Implementation

Created general lab group:
```bash
sudo groupadd researchers
```

Added all researchers to the group:
```bash
sudo usermod -aG researchers alice
sudo usermod -aG researchers bob
sudo usermod -aG researchers carol
```

**Verification (system-wide):**
```bash
getent group researchers
# Expected: researchers:x:1001:alice,bob,carol
```

**Verification (user perspective):**
```bash
su - alice
groups
# Expected: alice researchers
exit
```

### Critical Note

⚠️ Group membership applies at login. Users must log out and back in for `groups` command to reflect changes.

### Design Decision

The admin account was **not** added to the `researchers` group. Rationale:
- Admins manage access, not participate in collaboration
- Prevents accidental data ownership by admin
- Maintains clear audit trail
- Follows principle of least privilege

## Part 4 - Shared Directory (Initial Implementation)

### Goal

Create shared research directory accessible by all researchers, initially using standard permissions (deliberately incomplete to observe collaboration problem).

### Implementation

**1. Create base directory:**
```bash
sudo mkdir /research
```

**2. Assign group ownership:**
```bash
sudo chown root:researchers /research
```

**3. Set initial permissions:**
```bash
sudo chmod 775 /research
```

**Resulting permissions:**
```
drwxrwxr-x root researchers /research
```

- Owner (root): rwx (full access)
- Group (researchers): rwx (full access)
- Others: r-x (read and enter)

### Testing & Problem Discovery

**Test as alice:**
```bash
su - alice
cd /research
touch alice-file
ls -l
exit
```

**Test as bob:**
```bash
su - bob
cd /research
touch bob-file
ls -l
exit
```

### Observed Problem

File ownership inspection:
```bash
ls -l /research
```

**Result:**
```
-rw-r--r-- alice alice alice-file
-rw-r--r-- bob   bob   bob-file
```

**Issue Identified:**
Even though the directory is group-owned by `researchers` and group permissions allow writing, **new files inherit the user's primary group** (alice, bob), not the directory's group (researchers).

**Impact:**
- Files have inconsistent group ownership
- Collaboration becomes unreliable
- Permission management becomes complex
- Does not scale for team workflows

### Why This Matters

This is a **common misconfiguration** in real research environments. Stopping here demonstrates:
1. Understanding that permissions require more than just `chmod`
2. Awareness of file creation inheritance behavior
3. Ability to identify collaboration failures before they cause data issues

## Current Status

**Completed:**
- ✅ User model designed
- ✅ Three researcher accounts created and verified
- ✅ `researchers` group created with correct membership
- ✅ Shared `/research` directory created
- ✅ Initial permissions applied (775)
- ✅ Collaboration problem identified and documented

**Next Steps:**
- Fix file ownership inheritance using setgid bit
- Create project-specific directories with isolated access
- Test access control enforcement
- Validate collaboration workflows
- Document final permission model

## Key Learnings (So Far)

1. **Isolation First:** Users should start isolated. Shared access is granted intentionally, not by default.

2. **Groups Define Boundaries:** Linux permissions are group-driven. Correct group membership is prerequisite to functional permissions.

3. **Sequential Verification:** Testing at each layer (users → groups → directories) makes debugging predictable and systematic.

4. **Default Behavior Matters:** Understanding what Linux does automatically (primary group inheritance) is as important as what you configure explicitly.

5. **Problem-First Learning:** Observing the collaboration failure before applying the fix builds deeper understanding than following a recipe.

## Technical Commands Reference

```bash
# User verification
getent passwd <username>
id <username>

# Group verification
getent group <groupname>
groups <username>

# Permission inspection
ls -ld /path/to/directory
ls -l /path/to/directory

# User switching (for testing)
su - <username>

# Group membership (append mode)
sudo usermod -aG <group> <user>
```
