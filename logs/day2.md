# Day 2 - Multi-User Administration & Permissions

**Date:** 2026-01-02
**Planned Outcomes:** Implement group-based access control with collaborative file ownership
**Status:** ✅ Complete

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

## Part 5 - Fix Collaboration with setgid

### The Problem Recap

From Part 4, we observed:
- Files created in `/research` inherited users' primary groups (alice, bob)
- Should inherit directory's group (researchers) for collaboration
- Solution needed: automatic, scalable, no manual intervention

### The Solution: setgid Bit

**Applied setgid to `/research`:**
```bash
sudo chmod 2775 /research
```

**Permission breakdown:**
- `2` → setgid bit (enables group inheritance)
- `7` → owner (root) full access
- `7` → group (researchers) full access
- `5` → others read + execute

**Verification:**
```bash
ls -ld /research
# Expected: drwxrwsr-x root researchers /research
```

**Key indicator:** The `s` in group permissions (`rws`) confirms setgid is active.

### Testing the Fix

**Created new files:**
```bash
# As alice
su - alice
cd /research
touch alice-new
exit

# As bob
su - bob
cd /research
touch bob-new
exit
```

**Verified ownership:**
```bash
ls -l /research
```

**Result:**
```
-rw-r--r-- alice researchers alice-new
-rw-r--r-- bob   researchers bob-new
```

**Success criteria met:**
- Owner: Still individual users (alice, bob) ✅
- Group: Now `researchers` (inherited from directory) ✅

### Collaboration Validation

**Test cross-user editing:**
```bash
su - bob
echo "edit by bob" >> /research/alice-new
exit
```

**Result:** Success - Bob can edit Alice's file because both share the `researchers` group ownership.

### Why setgid is the Correct Solution

**✅ Advantages:**
- Automatic and centralized
- Scales to new users without admin intervention
- Matches real research environment patterns
- No manual file ownership changes needed
- Enforces consistent collaboration policy

**❌ Why NOT chmod 777:**
- Destroys ownership control
- Security risk (world-writable)
- Fails compliance audits
- Considered a red flag in professional environments

**❌ Why NOT manual chown:**
- Doesn't scale with user growth
- Reactive instead of preventative
- Error-prone and time-consuming

### Technical Insight

**setgid behavior on directories:**
- For executables: Process runs with group's permissions
- For directories: New files/subdirectories inherit directory's group
- This is exactly what shared research spaces require

## Part 6 - Project-Specific Isolation

### Goal

Implement restricted access where:
- Only selected researchers access project data
- Other researchers explicitly denied
- Admin retains control
- Collaboration works within project boundaries

### Implementation

**1. Create project group:**
```bash
sudo groupadd project1
```

**2. Add authorized users (alice, bob only):**
```bash
sudo usermod -aG project1 alice
sudo usermod -aG project1 bob
# carol deliberately excluded
```

**Verification:**
```bash
getent group project1
# Expected: project1:x:1002:alice,bob
```

**3. Create project directory:**
```bash
sudo mkdir /research/project1
```

**4. Configure ownership and permissions:**
```bash
sudo chown root:project1 /research/project1
sudo chmod 2770 /research/project1
```

**Permission breakdown:**
- `2` → setgid (group inheritance within project)
- `7` → owner (root) full access
- `7` → group (project1) full access
- `0` → **no access for others** (isolation enforced)

**Result:**
```bash
ls -ld /research/project1
# drwxrws--- root project1 /research/project1
```

### Access Control Testing

**Alice (project member) - should succeed:**
```bash
su - alice
cd /research/project1
touch alice-project
exit
```
Result: ✅ Success

**Bob (project member) - should succeed:**
```bash
su - bob
cd /research/project1
touch bob-project
exit
```
Result: ✅ Success

**Carol (not in project1) - should fail:**
```bash
su - carol
cd /research/project1
# Permission denied
```
Result: ✅ Success (denial is correct behavior)

### Collaboration Within Project

**Verified cross-editing within project:**
```bash
su - bob
echo "edit by bob" >> /research/project1/alice-project
exit
```

**Why this works:**
- Files inherit `project1` group (setgid)
- Both alice and bob are `project1` members
- Group has write permissions (7)

### What Was Achieved

**Layered access model:**
```
/research (775, group: researchers)
  ├── General files → all researchers can access
  └── /research/project1 (770, group: project1)
        └── Project files → only alice & bob can access
```

**Design characteristics:**
- Group-based isolation (no ACLs needed)
- Automatic inheritance (setgid on both levels)
- Zero manual file ownership management
- Admin-owned infrastructure (root owns directories)
- Scales cleanly as projects are added/removed

### Permission Inheritance Insight

**Initial state after mkdir:**
When `/research/project1` was created, it inherited:
- Group: `researchers` (from parent directory)
- Permissions: `drwxr-sr-x` (based on umask + inherited setgid)

**Problem with inherited state:**
- Group members could read but not write
- Non-members could still see directory contents
- Insufficient for project collaboration

**Fix applied:**
```bash
sudo chown root:project1 /research/project1  # Change group
sudo chmod 2770 /research/project1           # Enforce isolation
```

**Lesson:** Always explicitly set permissions on project directories. Inherited permissions rarely match security requirements.

## Day 2 Summary

**All objectives completed:**
- ✅ User model designed (alice, bob, carol + groups)
- ✅ Three researcher accounts created and verified
- ✅ `researchers` group created with correct membership
- ✅ Shared `/research` directory created
- ✅ Initial permissions applied (775) - problem identified
- ✅ setgid fix applied (2775) - collaboration enabled
- ✅ project1 group created with selective membership
- ✅ Project directory isolated (2770) - access enforced
- ✅ Access control validated (alice/bob yes, carol no)
- ✅ Cross-user collaboration tested and verified
- ✅ Permission inheritance behavior documented

**Implementation Notes:**

This implementation diverged from the original plan in `personal/overview.txt` (which called for faculty/grad/undergrad groups with /data directories). Instead, a simpler but equally effective model was implemented:
- General collaboration: `researchers` group with `/research` (2775)
- Project isolation: `project1` group with `/research/project1` (2770)

This approach demonstrates the same multi-user administration concepts while being more focused and easier to explain in interviews.

## Key Learnings

1. **Isolation First:** Users should start isolated. Shared access is granted intentionally, not by default.

2. **Groups Define Boundaries:** Linux permissions are group-driven. Correct group membership is prerequisite to functional permissions.

3. **Sequential Verification:** Testing at each layer (users → groups → directories) makes debugging predictable and systematic.

4. **Default Behavior Matters:** Understanding what Linux does automatically (primary group inheritance) is as important as what you configure explicitly.

5. **Problem-First Learning:** Observing the collaboration failure before applying the fix builds deeper understanding than following a recipe.

6. **setgid is Critical for Collaboration:** The setgid bit on directories changes file creation behavior - new files inherit the directory's group instead of the user's primary group. This is the foundation of scalable multi-user collaboration.

7. **Layered Access Control:** General access (`/research`) and restricted access (`/research/project1`) can coexist using different group assignments. This mirrors real research IT where base collaboration and project isolation must both exist.

8. **Inheritance vs. Intent:** When creating subdirectories, inherited permissions may not match security requirements. Always explicitly configure project directory permissions rather than relying on inheritance.

9. **Testing as Users:** Never assume permissions work - always test access by switching to actual user accounts (su - username), not just checking with ls -l as admin.

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

---

## References — Day 2

### Users & Groups

- **adduser**: [https://man7.org/linux/man-pages/man8/adduser.8.html](https://man7.org/linux/man-pages/man8/adduser.8.html)
- **useradd**: [https://man7.org/linux/man-pages/man8/useradd.8.html](https://man7.org/linux/man-pages/man8/useradd.8.html)
- **groupadd**: [https://man7.org/linux/man-pages/man8/groupadd.8.html](https://man7.org/linux/man-pages/man8/groupadd.8.html)
- **usermod**: [https://man7.org/linux/man-pages/man8/usermod.8.html](https://man7.org/linux/man-pages/man8/usermod.8.html)
- **getent**: [https://man7.org/linux/man-pages/man1/getent.1.html](https://man7.org/linux/man-pages/man1/getent.1.html)

### Files & Permissions

- **chmod**: [https://man7.org/linux/man-pages/man1/chmod.1.html](https://man7.org/linux/man-pages/man1/chmod.1.html)
- **chown**: [https://man7.org/linux/man-pages/man1/chown.1.html](https://man7.org/linux/man-pages/man1/chown.1.html)
- **umask**: [https://man7.org/linux/man-pages/man2/umask.2.html](https://man7.org/linux/man-pages/man2/umask.2.html)

### Permission Concepts

- **setgid directory bit**: [https://man7.org/linux/man-pages/man1/chmod.1.html#SETUID,_SETGID,_AND_STICKY_BITS](https://man7.org/linux/man-pages/man1/chmod.1.html#SETUID,_SETGID,_AND_STICKY_BITS)
