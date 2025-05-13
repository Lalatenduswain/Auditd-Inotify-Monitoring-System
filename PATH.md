## 🔧 Systemd and Monitoring Scripts Command Reference

### 🌀 Daemon Reload Commands

| Command |
|--------|
| `sudo systemctl daemon-reexec && sudo systemctl daemon-reload` |

---

### 📝 Edit and View Config Files

| File | Edit with `nano` | View with `cat` |
|------|------------------|-----------------|
| inotify-monitor.sh | `nano /usr/local/bin/inotify-monitor.sh` | `cat /usr/local/bin/inotify-monitor.sh` |
| audit-monitor.sh | `nano /usr/local/bin/audit-monitor.sh` | `cat /usr/local/bin/audit-monitor.sh` |
| audit-monitor.timer | `nano /etc/systemd/system/audit-monitor.timer` | `cat /etc/systemd/system/audit-monitor.timer` |
| audit-monitor.service | `nano /etc/systemd/system/audit-monitor.service` | `cat /etc/systemd/system/audit-monitor.service` |
| sensitive-files.rules | `nano /etc/audit/rules.d/sensitive-files.rules` | `cat /etc/audit/rules.d/sensitive-files.rules` |

---

### ✅ Enable / ❌ Disable Services and Timers

| Action | Command |
|--------|---------|
| Enable `inotify-monitor.service` | `sudo systemctl enable --now inotify-monitor.service` |
| Disable `inotify-monitor.service` | `sudo systemctl disable --now inotify-monitor.service` |
| Enable `audit-monitor.service` | `sudo systemctl enable --now audit-monitor.service` |
| Disable `audit-monitor.service` | `sudo systemctl disable --now audit-monitor.service` |
| Enable `audit-monitor.timer` | `sudo systemctl enable --now audit-monitor.timer` |
| Disable `audit-monitor.timer` | `sudo systemctl disable --now audit-monitor.timer` |

---

### ▶️ Start / ⏹️ Stop Services and Timers

| Action | Command |
|--------|---------|
| Start `inotify-monitor.service` | `sudo systemctl start inotify-monitor.service` |
| Stop `inotify-monitor.service` | `sudo systemctl stop inotify-monitor.service` |
| Start `audit-monitor.service` | `sudo systemctl start audit-monitor.service` |
| Stop `audit-monitor.service` | `sudo systemctl stop audit-monitor.service` |
| Start `audit-monitor.timer` | `sudo systemctl start audit-monitor.timer` |
| Stop `audit-monitor.timer` | `sudo systemctl stop audit-monitor.timer` |

---

### 🔁 Restart and 🔍 Status Check

| Action | Command |
|--------|---------|
| Restart `inotify-monitor.service` | `sudo systemctl restart inotify-monitor.service` |
| Status `inotify-monitor.service` | `sudo systemctl status inotify-monitor.service` |
| Restart `audit-monitor.service` | `sudo systemctl restart audit-monitor.service` |
| Status `audit-monitor.service` | `sudo systemctl status audit-monitor.service` |
| Restart `audit-monitor.timer` | `sudo systemctl restart audit-monitor.timer` |
| Status `audit-monitor.timer` | `sudo systemctl status audit-monitor.timer` |

---

### 🧹 Clear Mail Log and Queue

| Command |
|---------|
| `sudo truncate -s 0 /var/log/mail.log && sudo postsuper -d ALL && sudo tail -f /var/log/mail.log` |
