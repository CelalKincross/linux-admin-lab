# Day 2 Practice Exercises - Users, Groups, and Permissions

> Hands-on practice to reinforce multi-user Linux administration concepts

## Setup

SSH into your lab-admin VM for these exercises:
```bash
ssh youruser@lab-admin
```

## Part 1: User Creation Basics

### Exercise 1.1: Create Your First User
```bash
# Create a user named testuser1
sudo useradd -m -s /bin/bash -c "Test User One" testuser1

# Set a password
sudo passwd testuser1

# Verify it was created
id testuser1
grep testuser1 /etc/passwd
ls -la /home/testuser1
```

**Questions:**
1. What UID was assigned to testuser1?
2. What is the primary group?
3. What files were created in the home directory?

### Exercise 1.2: Understand User Files
```bash
# View user entry in passwd
grep testuser1 /etc/passwd

# View user entry in shadow (encrypted password)
sudo grep testuser1 /etc/shadow

# View user's group
grep testuser1 /etc/group
```

**Questions:**
1. What's the difference between /etc/passwd and /etc/shadow?
2. Why can't regular users read /etc/shadow?

### Exercise 1.3: Switch Users
```bash
# Switch to testuser1
su - testuser1
# Enter password when prompted

# Check who you are
whoami
pwd
id

# Return to your original user
exit
```

## Part 2: Group Management

### Exercise 2.1: Create Groups
```bash
# Create research groups
sudo groupadd faculty
sudo groupadd grad
sudo groupadd undergrad

# Verify creation
getent group faculty
getent group grad
getent group undergrad
```

### Exercise 2.2: Add Users to Groups
```bash
# Create users for each group
sudo useradd -m -s /bin/bash -c "Professor X" prof_x
sudo useradd -m -s /bin/bash -c "Grad Student A" grad_a
sudo useradd -m -s /bin/bash -c "Undergrad A" ug_a

# Add users to their respective groups
sudo usermod -aG faculty prof_x
sudo usermod -aG grad grad_a
sudo usermod -aG undergrad ug_a

# Verify group membership
groups prof_x
groups grad_a
groups ug_a

# View group members
getent group faculty
getent group grad
```

### Exercise 2.3: Multiple Group Membership
```bash
# Add grad_a to both grad and faculty groups
sudo usermod -aG faculty grad_a

# Verify
groups grad_a
id grad_a
```

**Question:** Why would a grad student need to be in both groups?

## Part 3: Permissions Fundamentals

### Exercise 3.1: Create Test Files
```bash
# Create test directory
mkdir ~/permission_practice
cd ~/permission_practice

# Create files with different permissions
touch file1.txt
touch file2.txt
touch file3.txt

# View permissions
ls -l
```

**Observe:** What are the default permissions?

### Exercise 3.2: Change Permissions (Symbolic)
```bash
# Make file1 read-only for everyone
chmod a-w file1.txt
ls -l file1.txt

# Try to write to it
echo "test" >> file1.txt  # Should fail

# Add write back for owner
chmod u+w file1.txt
echo "test" >> file1.txt  # Should work

# Make file2 executable
chmod +x file2.txt
ls -l file2.txt
```

### Exercise 3.3: Change Permissions (Octal)
```bash
# Set different permission patterns
chmod 644 file1.txt   # rw-r--r--
chmod 755 file2.txt   # rwxr-xr-x
chmod 600 file3.txt   # rw-------

# Verify
ls -l
```

**Exercise:** Calculate the octal number for these permissions:
1. rwxrwx---
2. rw-rw-r--
3. r-xr-x---

### Exercise 3.4: Directory Permissions
```bash
# Create test directory
mkdir testdir
chmod 755 testdir

# What does this mean?
ls -ld testdir

# Try different permissions
chmod 750 testdir  # Owner and group can access, others can't
chmod 700 testdir  # Only owner can access
chmod 755 testdir  # Everyone can read and enter

# Create file inside
touch testdir/inside.txt
ls -l testdir/
```

**Question:** What happens if a directory has read permission but not execute?

## Part 4: Ownership

### Exercise 4.1: Change File Owner
```bash
# Create a test file
touch myfile.txt
ls -l myfile.txt

# Change owner (need sudo)
sudo chown prof_x myfile.txt
ls -l myfile.txt

# Change owner and group
sudo chown prof_x:faculty myfile.txt
ls -l myfile.txt

# Change only group
sudo chgrp grad myfile.txt
ls -l myfile.txt
```

### Exercise 4.2: Recursive Ownership
```bash
# Create directory structure
mkdir -p project/{data,scripts,docs}
touch project/data/file1.txt
touch project/scripts/script.sh
touch project/docs/readme.md

# Change ownership recursively
sudo chown -R prof_x:faculty project/
ls -lR project/
```

## Part 5: Real-World Scenarios

### Scenario 5.1: Shared Project Directory
```bash
# Create shared project directory
sudo mkdir -p /data/projects/projectA
sudo chown prof_x:faculty /data/projects/projectA
sudo chmod 770 /data/projects/projectA

# Set setgid so new files inherit group
sudo chmod g+s /data/projects/projectA

# Verify
ls -ld /data/projects/projectA
```

**As prof_x, create a file:**
```bash
sudo -u prof_x touch /data/projects/projectA/data.csv
ls -l /data/projects/projectA/
```

**Question:** What group owns data.csv? Why?

### Scenario 5.2: Read-Only Archive
```bash
# Create archive directory
sudo mkdir -p /data/archive
sudo chown root:faculty /data/archive
sudo chmod 755 /data/archive

# Add a file
sudo touch /data/archive/old_data.csv
sudo chmod 444 /data/archive/old_data.csv

# Try to modify it (should fail)
sudo -u grad_a echo "test" >> /data/archive/old_data.csv
```

### Scenario 5.3: User's Private Directory
```bash
# Each user's home should be private
sudo chmod 700 /home/grad_a
sudo chmod 700 /home/prof_x
sudo chmod 700 /home/ug_a

# Verify others can't access
ls -ld /home/grad_a
sudo -u ug_a ls /home/grad_a  # Should fail
```

## Part 6: Testing Access Control

### Exercise 6.1: Test Read Access
```bash
# Create test file
sudo mkdir -p /data/shared
sudo touch /data/shared/test.txt
sudo chmod 644 /data/shared/test.txt
sudo chown prof_x:faculty /data/shared/test.txt

# Test as different users
sudo -u prof_x cat /data/shared/test.txt     # Should work
sudo -u grad_a cat /data/shared/test.txt     # Should work (world-readable)
sudo -u ug_a cat /data/shared/test.txt       # Should work (world-readable)
```

### Exercise 6.2: Test Write Access
```bash
# Test write permissions
sudo -u prof_x echo "data" >> /data/shared/test.txt    # Should work (owner)
sudo -u grad_a echo "data" >> /data/shared/test.txt    # Should fail (not owner, no group write)
sudo -u ug_a echo "data" >> /data/shared/test.txt      # Should fail (no write permission)
```

### Exercise 6.3: Test Directory Access
```bash
# Create restricted directory
sudo mkdir /data/faculty_only
sudo chown prof_x:faculty /data/faculty_only
sudo chmod 770 /data/faculty_only

# Test access
sudo -u prof_x ls /data/faculty_only     # Should work
sudo -u grad_a ls /data/faculty_only     # Should fail (not in faculty group)
sudo -u ug_a ls /data/faculty_only       # Should fail
```

## Part 7: Special Permissions

### Exercise 7.1: SetGID on Directory
```bash
# Create collaboration directory
sudo mkdir /data/collab
sudo chown prof_x:grad /data/collab
sudo chmod 2775 /data/collab

# Verify setgid
ls -ld /data/collab  # Look for 's' in group execute position

# Create file as different user
sudo -u grad_a touch /data/collab/gradfile.txt
ls -l /data/collab/

# Check group ownership
ls -l /data/collab/gradfile.txt
```

**Question:** What group owns gradfile.txt? Why is this useful?

### Exercise 7.2: Sticky Bit
```bash
# Create shared temp directory
sudo mkdir /data/temp
sudo chmod 1777 /data/temp

# Verify sticky bit
ls -ld /data/temp  # Look for 't' at the end

# Create files as different users
sudo -u prof_x touch /data/temp/prof_file.txt
sudo -u grad_a touch /data/temp/grad_file.txt

# Try to delete other user's file (should fail)
sudo -u grad_a rm /data/temp/prof_file.txt  # Should fail
sudo -u prof_x rm /data/temp/grad_file.txt  # Should fail

# Can delete own file
sudo -u grad_a rm /data/temp/grad_file.txt  # Should work
```

## Part 8: Troubleshooting Practice

### Exercise 8.1: Permission Denied
```bash
# Create scenario
sudo touch /data/secret.txt
sudo chmod 000 /data/secret.txt

# Try to read (fails)
cat /data/secret.txt

# Diagnose
ls -l /data/secret.txt
# Fix: Add read permission
sudo chmod 644 /data/secret.txt
cat /data/secret.txt
```

### Exercise 8.2: Can't Execute Script
```bash
# Create script
echo '#!/bin/bash' > script.sh
echo 'echo "Hello"' >> script.sh

# Try to run (fails)
./script.sh

# Diagnose
ls -l script.sh
# Fix: Add execute permission
chmod +x script.sh
./script.sh
```

### Exercise 8.3: Can't Enter Directory
```bash
# Create scenario
mkdir testdir
chmod 644 testdir  # rw-r--r-- (no execute!)

# Try to enter (fails)
cd testdir

# Diagnose
ls -ld testdir
# Fix: Add execute permission
chmod 755 testdir
cd testdir
```

## Part 9: Cleanup

```bash
# Remove test users
sudo userdel -r testuser1
sudo userdel -r prof_x
sudo userdel -r grad_a
sudo userdel -r ug_a

# Remove test groups
sudo groupdel faculty
sudo groupdel grad
sudo groupdel undergrad

# Clean up test files
rm -rf ~/permission_practice
sudo rm -rf /data
```

## Knowledge Check

After completing these exercises, you should be able to:
- [ ] Create users with specific settings
- [ ] Add users to groups
- [ ] Set permissions using both symbolic and octal notation
- [ ] Change file ownership
- [ ] Explain what setgid and sticky bit do
- [ ] Test access control as different users
- [ ] Troubleshoot common permission issues
- [ ] Design directory structures with appropriate permissions

## Challenge Exercises

### Challenge 1: Design a Multi-Project Structure
Create a directory structure for two research projects where:
- Each project has a faculty lead and 2 grad students
- Faculty can read/write all project files
- Grad students can only access their own project
- Both projects share a common "references" directory (read-only for grads)
- Archive directory is read-only for everyone

### Challenge 2: Automated User Creation
Write a bash script that:
1. Reads a CSV file with username, full name, and group
2. Creates the user if it doesn't exist
3. Adds user to appropriate group
4. Sets up home directory with correct permissions
5. Logs all actions

### Challenge 3: Permission Audit
Write a script that:
1. Finds all files in /data owned by a specific user
2. Finds all files with permission 777 (security risk!)
3. Lists all directories without execute permission
4. Outputs results to a report

## Next Steps

1. Complete all exercises in Part 1-8
2. Try the challenge exercises
3. Document what you learned in your learning journal
4. Move on to Day 2 implementation in the main lab
5. Reference this when you get stuck!
