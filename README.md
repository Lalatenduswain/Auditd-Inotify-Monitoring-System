# Auditd + Inotify Monitoring System

## 🎯 Purpose

This project provides a secure audit and email alerting system to monitor access to sensitive Linux configuration files such as `/etc/passwd`, `/etc/shadow`, and `/etc/ssh/sshd_config` using:

* `auditd` (syscall auditing)
* `inotifywait` (real-time file access monitoring)
* Email alerts with HTML formatting
* `systemd` service and timer integration

---

## 📁 Repository Structure

```
.
├── rules/
│   └── sensitive-files.rules            # auditd syscall rules
├── scripts/
│   ├── audit-monitor.sh                # auditd-based HTML email alerts
│   ├── inotify-monitor.sh              # inotify-based alerting
│   └── install-auditd-rules.sh         # setup + verification script
├── systemd/
│   ├── audit-monitor.service
│   ├── audit-monitor.timer
│   └── inotify-monitor.service
├── logs/                               # directory to collect audit logs
├── README.md
└── LICENSE
```

---

## ✅ Sensitive Files Covered

This repo is preconfigured to watch access to:

| File                   | Purpose                      | Audit Key           |
| ---------------------- | ---------------------------- | ------------------- |
| `/etc/passwd`          | User account metadata        | `passwd_watch`      |
| `/etc/shadow`          | Hashed user passwords        | `shadow_watch`      |
| `/etc/ssh/sshd_config` | SSH server settings          | `sshd_config_watch` |
| `/etc/sudoers`         | Sudo privilege config        | `sudoers_watch`     |
| `/etc/fstab`           | Filesystem mount information | `fstab_watch`       |
| `/etc/group`           | Group definitions            | `group_watch`       |

---

## 🧪 How to Install the Audit Rules

Run:

```bash
bash scripts/install-auditd-rules.sh
```

This will:

* Copy `sensitive-files.rules` to `/etc/audit/rules.d/`
* Reload audit rules
* Verify success with `auditctl -l`

---

## 📦 Sample Rule: `rules/sensitive-files.rules`

```bash
# passwd
-a always,exit -S all -F path=/etc/passwd -F perm=r -F auid>=1000 -F auid!=4294967295 -k passwd_watch

# shadow
-a always,exit -S all -F path=/etc/shadow -F perm=r -F auid>=1000 -F auid!=4294967295 -k shadow_watch

# sshd config
-a always,exit -S all -F path=/etc/ssh/sshd_config -F perm=r -F auid>=1000 -F auid!=4294967295 -k sshd_config_watch

# sudoers
-a always,exit -S all -F path=/etc/sudoers -F perm=r -F auid>=1000 -F auid!=4294967295 -k sudoers_watch

# fstab
-a always,exit -S all -F path=/etc/fstab -F perm=r -F auid>=1000 -F auid!=4294967295 -k fstab_watch

# group
-a always,exit -S all -F path=/etc/group -F perm=r -F auid>=1000 -F auid!=4294967295 -k group_watch
```

---

## 📜 Script: `scripts/install-auditd-rules.sh`

```bash
#!/bin/bash

RULES_FILE="rules/sensitive-files.rules"
DEST="/etc/audit/rules.d/sensitive-files.rules"

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root." >&2
  exit 1
fi

if [[ ! -f "$RULES_FILE" ]]; then
  echo "[ERROR] Rule file not found: $RULES_FILE" >&2
  exit 1
fi

echo "[INFO] Installing auditd rules..."
cp "$RULES_FILE" "$DEST"
augenrules --load

echo "[INFO] Verifying installed auditd rules..."
auditctl -l | grep -E 'passwd_watch|shadow_watch|sshd_config_watch|sudoers_watch|fstab_watch|group_watch'
```

---

## 🛠️ Setup Instructions

### 1. Install Required Packages

```bash
# Debian/Ubuntu:
sudo apt install inotify-tools mailutils -y

# RHEL/CentOS:
sudo yum install inotify-tools mailx -y
```

### 2. Setup Log Files

```bash
sudo touch /var/log/inotify_access.log
sudo chmod 640 /var/log/inotify_access.log
sudo chown root:adm /var/log/inotify_access.log

sudo touch /var/log/audit_email_alert.log
sudo chmod 640 /var/log/audit_email_alert.log
sudo chown root:adm /var/log/audit_email_alert.log
```

### 3. Deploy Scripts

```bash
sudo cp scripts/inotify-monitor.sh /usr/local/bin/inotify-monitor.sh
sudo cp scripts/audit-monitor.sh /usr/local/bin/audit-monitor.sh
sudo chmod +x /usr/local/bin/*.sh
```

### 4. Create Systemd Services

```bash
sudo cp systemd/audit-monitor.service /etc/systemd/system/
sudo cp systemd/audit-monitor.timer /etc/systemd/system/
sudo cp systemd/inotify-monitor.service /etc/systemd/system/
```

### 5. Enable Services

```bash
sudo systemctl daemon-reexec && sudo systemctl daemon-reload
sudo systemctl enable --now inotify-monitor.service
sudo systemctl enable --now audit-monitor.timer
```

To disable old setups:

```bash
sudo systemctl disable --now passwd-watch.service
sudo rm /etc/systemd/system/passwd-watch.service
sudo rm /usr/local/bin/monitor-passwd-read.sh
```

---

## 🧪 Testing

```bash
cat /etc/passwd
sudo -u nobody cat /etc/shadow
ausearch -k shadow_watch -ts recent
