# Linux Command Cheatsheet

## User Management

| Command | Purpose | Example |
|---------|---------|---------|
| `useradd` | Create user | `sudo useradd -m -s /bin/bash grad_a` |
| `passwd` | Set password | `sudo passwd grad_a` |
| `usermod` | Modify user | `sudo usermod -aG faculty grad_a` |
| `userdel` | Delete user | `sudo userdel -r grad_a` |
| `id` | Show user info | `id grad_a` |
| `who` | Show logged in users | `who` |
| `whoami` | Show current user | `whoami` |
| `su` | Switch user | `su - grad_a` |
| `sudo -u` | Run as user | `sudo -u grad_a cat file.txt` |

## Group Management

| Command | Purpose | Example |
|---------|---------|---------|
| `groupadd` | Create group | `sudo groupadd faculty` |
| `groupdel` | Delete group | `sudo groupdel faculty` |
| `gpasswd -a` | Add user to group | `sudo gpasswd -a grad_a faculty` |
| `gpasswd -d` | Remove from group | `sudo gpasswd -d grad_a faculty` |
| `groups` | Show user's groups | `groups grad_a` |
| `getent group` | Show group members | `getent group faculty` |

## Permissions

| Command | Purpose | Example |
|---------|---------|---------|
| `chmod` | Change permissions | `chmod 755 script.sh` |
| `chown` | Change owner | `chown user:group file.txt` |
| `chgrp` | Change group | `chgrp faculty file.txt` |
| `umask` | Default permissions | `umask 022` |
| `ls -l` | List with permissions | `ls -l /data/` |
| `stat` | Detailed file info | `stat file.txt` |

### chmod Quick Reference

| Number | Binary | Permissions |
|--------|--------|-------------|
| 0 | 000 | --- |
| 1 | 001 | --x |
| 2 | 010 | -w- |
| 3 | 011 | -wx |
| 4 | 100 | r-- |
| 5 | 101 | r-x |
| 6 | 110 | rw- |
| 7 | 111 | rwx |

## File Operations

| Command | Purpose | Example |
|---------|---------|---------|
| `ls` | List files | `ls -la` |
| `cd` | Change directory | `cd /data/shared` |
| `pwd` | Print working dir | `pwd` |
| `mkdir` | Create directory | `mkdir -p /data/projects/projectA` |
| `rmdir` | Remove empty dir | `rmdir /data/old` |
| `rm` | Remove file | `rm -rf /data/temp/` |
| `cp` | Copy | `cp -r source/ dest/` |
| `mv` | Move/rename | `mv old.txt new.txt` |
| `touch` | Create empty file | `touch file.txt` |
| `cat` | View file | `cat file.txt` |
| `less` | Page through file | `less large.log` |
| `head` | First lines | `head -n 20 file.txt` |
| `tail` | Last lines | `tail -f /var/log/syslog` |
| `grep` | Search in files | `grep "error" /var/log/syslog` |
| `find` | Find files | `find /data -name "*.csv"` |

## System Information

| Command | Purpose | Example |
|---------|---------|---------|
| `hostname` | Show hostname | `hostname` |
| `hostnamectl` | Host info | `hostnamectl` |
| `uname` | System info | `uname -a` |
| `df` | Disk usage | `df -h` |
| `du` | Directory size | `du -sh /data/` |
| `free` | Memory usage | `free -h` |
| `uptime` | System uptime | `uptime` |
| `date` | Show date/time | `date` |
| `timedatectl` | Time settings | `timedatectl` |

## Process Management

| Command | Purpose | Example |
|---------|---------|---------|
| `ps` | Show processes | `ps aux` |
| `top` | Monitor processes | `top` |
| `htop` | Better top | `htop` |
| `kill` | Kill process | `kill -9 1234` |
| `killall` | Kill by name | `killall nginx` |
| `pgrep` | Find process ID | `pgrep nginx` |
| `systemctl` | Manage services | `systemctl status nginx` |

## systemd

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl start` | Start service | `sudo systemctl start nginx` |
| `systemctl stop` | Stop service | `sudo systemctl stop nginx` |
| `systemctl restart` | Restart service | `sudo systemctl restart nginx` |
| `systemctl reload` | Reload config | `sudo systemctl reload nginx` |
| `systemctl enable` | Start on boot | `sudo systemctl enable nginx` |
| `systemctl disable` | Don't start on boot | `sudo systemctl disable nginx` |
| `systemctl status` | Check status | `systemctl status nginx` |
| `systemctl list-units` | List services | `systemctl list-units --type=service` |
| `journalctl` | View logs | `journalctl -u nginx -f` |

## Package Management (Debian/Ubuntu)

| Command | Purpose | Example |
|---------|---------|---------|
| `apt update` | Update package list | `sudo apt update` |
| `apt upgrade` | Upgrade packages | `sudo apt upgrade -y` |
| `apt install` | Install package | `sudo apt install nginx` |
| `apt remove` | Remove package | `sudo apt remove nginx` |
| `apt search` | Search packages | `apt search nginx` |
| `apt show` | Package info | `apt show nginx` |
| `apt list` | List installed | `apt list --installed` |
| `dpkg -l` | List packages | `dpkg -l | grep nginx` |

## Networking

| Command | Purpose | Example |
|---------|---------|---------|
| `ip addr` | Show IP addresses | `ip addr show` |
| `ip route` | Show routes | `ip route show` |
| `ping` | Test connectivity | `ping lab-admin` |
| `netstat` | Network stats | `netstat -tulpn` |
| `ss` | Socket stats | `ss -tulpn` |
| `curl` | HTTP request | `curl https://example.com` |
| `wget` | Download file | `wget https://example.com/file` |

## SSH

| Command | Purpose | Example |
|---------|---------|---------|
| `ssh` | Connect to host | `ssh user@lab-admin` |
| `ssh-keygen` | Generate key | `ssh-keygen -t ed25519` |
| `ssh-copy-id` | Copy key to host | `ssh-copy-id user@lab-admin` |
| `scp` | Secure copy | `scp file.txt user@host:/path/` |
| `rsync` | Sync files | `rsync -avz source/ dest/` |

## File Content

| Command | Purpose | Example |
|---------|---------|---------|
| `cat` | Show file | `cat file.txt` |
| `less` | Page file | `less file.txt` |
| `head` | First lines | `head -20 file.txt` |
| `tail` | Last lines | `tail -f log.txt` |
| `grep` | Search | `grep "error" log.txt` |
| `sed` | Stream edit | `sed 's/old/new/g' file.txt` |
| `awk` | Text processing | `awk '{print $1}' file.txt` |
| `wc` | Word count | `wc -l file.txt` |
| `sort` | Sort lines | `sort file.txt` |
| `uniq` | Remove duplicates | `sort file.txt | uniq` |

## Archives

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -czf` | Create tar.gz | `tar -czf archive.tar.gz directory/` |
| `tar -xzf` | Extract tar.gz | `tar -xzf archive.tar.gz` |
| `tar -tf` | List contents | `tar -tf archive.tar.gz` |
| `zip` | Create zip | `zip -r archive.zip directory/` |
| `unzip` | Extract zip | `unzip archive.zip` |

## Backup with rsync

| Command | Purpose |
|---------|---------|
| `rsync -av` | Archive mode, verbose |
| `rsync -avz` | Archive mode, compressed |
| `rsync -av --delete` | Delete files in dest not in source |
| `rsync -av --dry-run` | Test without making changes |
| `rsync -av --exclude='*.log'` | Exclude pattern |

Example:
```bash
rsync -avz --delete /data/ user@lab-backup:/backup/data/
```

## Text Editors

| Command | Purpose |
|---------|---------|
| `nano` | Simple editor |
| `vim` | Advanced editor |
| `vi` | Classic editor |

Basic vim:
- `i` - insert mode
- `Esc` - command mode
- `:w` - save
- `:q` - quit
- `:wq` - save and quit
- `:q!` - quit without saving

## Cron

| Command | Purpose | Example |
|---------|---------|---------|
| `crontab -e` | Edit cron jobs | `crontab -e` |
| `crontab -l` | List cron jobs | `crontab -l` |
| `crontab -r` | Remove all jobs | `crontab -r` |

Cron syntax:
```
* * * * * command
│ │ │ │ │
│ │ │ │ └─ day of week (0-7, 0 or 7 = Sunday)
│ │ │ └─── month (1-12)
│ │ └───── day of month (1-31)
│ └─────── hour (0-23)
└───────── minute (0-59)
```

Examples:
```bash
0 2 * * * /backup.sh          # Daily at 2am
*/15 * * * * /check.sh        # Every 15 minutes
0 0 * * 0 /weekly.sh          # Weekly on Sunday
```

## Logs

| Location | Purpose |
|----------|---------|
| `/var/log/syslog` | System messages |
| `/var/log/auth.log` | Authentication |
| `/var/log/kern.log` | Kernel messages |
| `/var/log/apache2/` | Apache logs |
| `journalctl` | systemd logs |

journalctl examples:
```bash
journalctl -u nginx              # Logs for nginx service
journalctl -f                    # Follow logs (like tail -f)
journalctl -p err                # Only errors
journalctl --since "1 hour ago"  # Recent logs
journalctl -b                    # Since last boot
```

## Common Patterns

**Find and delete old files:**
```bash
find /tmp -type f -mtime +7 -delete
```

**Find large files:**
```bash
find /data -type f -size +100M
```

**Count lines in multiple files:**
```bash
wc -l *.txt
```

**Search for text recursively:**
```bash
grep -r "search term" /path/
```

**Replace text in file:**
```bash
sed -i 's/old/new/g' file.txt
```

**Check disk space by directory:**
```bash
du -sh /* | sort -hr
```

**Monitor log file:**
```bash
tail -f /var/log/syslog | grep error
```

**Check which ports are listening:**
```bash
sudo ss -tulpn
```
