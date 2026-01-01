# Day 2 Learning: Users, Groups, and Permissions

## Pre-Work: Read This Before Starting Day 2

### Why Multi-User Management Matters

In research computing environments:
- Multiple people need access to shared systems
- Different people need different levels of access
- Data security requires boundaries between users
- Projects often have shared resources that need group collaboration
- Some resources must be read-only to prevent accidental changes

### Core Concepts

## 1. Users in Linux

Every person who accesses a Linux system needs a user account.

**What a user account includes:**
- Username (login name)
- User ID (UID) - a number that uniquely identifies the user
- Primary group
- Home directory
- Login shell
- Password (encrypted)

**Where user information is stored:**
- `/etc/passwd` - User account information (non-sensitive)
- `/etc/shadow` - Encrypted passwords (sensitive, restricted access)
- `/etc/group` - Group information

**Viewing /etc/passwd:**
```bash
cat /etc/passwd
```

Format: `username:x:UID:GID:comment:home_directory:shell`

Example:
```
grad_a:x:1001:1002:Graduate Student A:/home/grad_a:/bin/bash
```

Breaking it down:
- `grad_a` - username
- `x` - password placeholder (actual password in /etc/shadow)
- `1001` - User ID (UID)
- `1002` - Primary Group ID (GID)
- `Graduate Student A` - Comment/description field
- `/home/grad_a` - Home directory
- `/bin/bash` - Default shell

## 2. Groups in Linux

Groups allow multiple users to share access to files and directories.

**Why use groups?**
- Give multiple users access to shared project files
- Manage permissions collectively instead of per-user
- Reflect organizational structure (faculty, grad students, etc.)

**Types of groups:**
- **Primary group**: Every user has one primary group
- **Secondary groups**: Users can belong to multiple additional groups

**Viewing /etc/group:**
```bash
cat /etc/group
```

Format: `groupname:x:GID:member1,member2,member3`

Example:
```
faculty:x:1001:prof_x
grad:x:1002:grad_a,grad_b
```

## 3. The Linux Permission Model

Every file and directory has permissions for three categories:

1. **Owner (u)** - The user who owns the file
2. **Group (g)** - The group that owns the file
3. **Others (o)** - Everyone else

**Three types of permissions:**
- **r (read)** - View file contents or list directory contents
- **w (write)** - Modify file or create/delete files in directory
- **x (execute)** - Run file as program or enter directory

**Reading `ls -l` output:**
```bash
ls -l /data/shared
-rw-r--r-- 1 prof_x faculty 1024 Jan 01 10:00 data.csv
drwxrwx--- 2 prof_x grad    4096 Jan 01 10:00 projectA/
```

Breaking down the first line:
```
-rw-r--r-- 1 prof_x faculty 1024 Jan 01 10:00 data.csv
│││││││││  │   │      │       │      │          │
│││││││││  │   │      │       │      │          └─ filename
│││││││││  │   │      │       │      └─ date modified
│││││││││  │   │      │       └─ size in bytes
│││││││││  │   │      └─ group owner
│││││││││  │   └─ user owner
│││││││││  └─ number of hard links
│└┼┼┼┼┼┼┼─ file type: - (regular file), d (directory), l (link)
│ │││││└─ others: r-- (read-only)
│ ││└┼┼─ group: r-- (read-only)
│ └┼ └┼─ owner: rw- (read and write)
└────── file type
```

**Permission numbers (octal notation):**
Each permission set can be represented as a number:
- r (read) = 4
- w (write) = 2
- x (execute) = 1

Add them up for each category:
- 7 (rwx) = 4+2+1 = full access
- 6 (rw-) = 4+2+0 = read and write
- 5 (r-x) = 4+0+1 = read and execute
- 4 (r--) = 4+0+0 = read only
- 0 (---) = no access

Example: `chmod 750 file`
- 7 (owner): rwx
- 5 (group): r-x
- 0 (others): ---

## 4. Essential Commands

### User Management

**Create a user:**
```bash
sudo useradd -m -s /bin/bash -c "Graduate Student A" grad_a
```
Flags:
- `-m` - create home directory
- `-s /bin/bash` - set default shell
- `-c "comment"` - add description

**Set user password:**
```bash
sudo passwd grad_a
```

**Modify a user:**
```bash
sudo usermod -aG faculty grad_a  # Add user to secondary group
```

**Delete a user:**
```bash
sudo userdel -r grad_a  # -r removes home directory too
```

**View user info:**
```bash
id grad_a           # Show UID, GID, and groups
groups grad_a       # Show groups user belongs to
finger grad_a       # Detailed user information (if installed)
```

### Group Management

**Create a group:**
```bash
sudo groupadd faculty
```

**Add user to group:**
```bash
sudo usermod -aG faculty prof_x  # -a = append, -G = supplementary groups
```

**Remove user from group:**
```bash
sudo gpasswd -d grad_a faculty
```

**Delete a group:**
```bash
sudo groupdel faculty
```

**View group members:**
```bash
getent group faculty
```

### Permission Management

**Change file owner:**
```bash
sudo chown prof_x:faculty file.txt
```

**Change file permissions (symbolic):**
```bash
chmod u+x script.sh      # Add execute for owner
chmod g-w file.txt       # Remove write for group
chmod o+r data.csv       # Add read for others
chmod a+r file.txt       # Add read for all (user, group, others)
```

**Change file permissions (octal):**
```bash
chmod 755 script.sh      # rwxr-xr-x
chmod 644 file.txt       # rw-r--r--
chmod 750 directory/     # rwxr-x---
```

**Recursive permission change:**
```bash
chmod -R 755 /data/shared/   # Apply to directory and all contents
chown -R prof_x:faculty /data/projectA/
```

### Permission Checking

**Test access as different user:**
```bash
sudo -u grad_a cat /data/shared/file.txt
sudo -u grad_a ls /data/projectA/
```

**Switch to another user:**
```bash
su - grad_a    # Switch user (will prompt for grad_a's password)
```

## 5. Special Permissions

### SetUID (Set User ID)
When set on an executable, it runs with the owner's permissions.
```bash
chmod u+s /usr/bin/program
# or
chmod 4755 /usr/bin/program
```

### SetGID (Set Group ID)
On executable: runs with group's permissions
On directory: files created inherit directory's group
```bash
chmod g+s /data/shared/
# or
chmod 2775 /data/shared/
```

### Sticky Bit
On directory: only file owner can delete their files (like /tmp)
```bash
chmod +t /data/shared/
# or
chmod 1777 /data/shared/
```

## 6. Common Permission Patterns

**Private file (only owner can read/write):**
```bash
chmod 600 private.txt
# rw-------
```

**Shared project directory (group collaboration):**
```bash
chmod 770 /data/projectA/
chown -R :faculty /data/projectA/
chmod g+s /data/projectA/  # New files inherit group
# rwxrwx---
```

**Public read-only data:**
```bash
chmod 644 data.csv
# rw-r--r--
```

**Executable script:**
```bash
chmod 755 script.sh
# rwxr-xr-x
```

**Archive directory (read-only for security):**
```bash
chmod 555 /data/archive/
# r-xr-xr-x
```

## Practice Exercises

Before starting Day 2 implementation, try these on your VMs:

1. Create a test user and switch to it
2. Create a file as that user and check its permissions
3. Try to access another user's home directory
4. Create a group and add multiple users to it
5. Make a directory that group members can write to
6. Set up a directory where files automatically inherit the group

## Common Gotchas

1. **Forgot sudo**: Most user/group/permission commands need root
2. **Wrong group syntax**: `usermod -G` REPLACES groups, use `-aG` to APPEND
3. **Directory permissions**: Need `x` (execute) to `cd` into a directory
4. **Uppercase vs lowercase**: `chmod u+X` (uppercase X) only adds execute to directories
5. **Recursive changes**: Be careful with `chmod -R` - can break system files

## Research Questions

Before starting Day 2, research and answer:

1. What's the difference between `/etc/passwd` and `/etc/shadow`?
2. Why do service accounts often have `/bin/false` or `/usr/sbin/nologin` as their shell?
3. What is umask and how does it affect newly created files?
4. Why shouldn't you use user accounts for system services?

## Learning Validation

You're ready for Day 2 implementation when you can:
- [ ] Explain what UID and GID are
- [ ] Describe the three permission categories (owner, group, others)
- [ ] Calculate permission numbers (e.g., what's 644 in rwx format?)
- [ ] Explain why groups are useful in multi-user environments
- [ ] Describe what happens when you `cd` into a directory permission-wise

## Next Steps

After reading this:
1. SSH into your lab-admin VM
2. Practice creating users and groups
3. Experiment with permissions on test files
4. Then start Day 2 implementation following logs/day2.md
