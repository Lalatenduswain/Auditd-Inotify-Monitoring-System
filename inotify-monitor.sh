#!/bin/bash

# Variables
LOGFILE="/var/log/inotify_access.log"
EMAIL="lalatendu@ceruleaninfotech.com"
WATCHED_FILES=("/etc/passwd" "/etc/shadow" "/etc/ssh/sshd_config")
SKIP_FILES=("/etc/motd" "/etc/issue")  # Add noisy/unwanted files here

echo "[INFO] Starting inotify monitor..."

while true; do
    FILE=$(inotifywait -e access,open --format "%w%f" "${WATCHED_FILES[@]}" 2>/dev/null)

    [[ -z "$FILE" ]] && continue

    # Skip noisy system files
    if [[ " ${SKIP_FILES[@]} " =~ " $FILE " ]]; then
        continue
    fi

    TIME=$(date '+%Y-%m-%d %H:%M:%S')
    SUBJECT="INOTIFY ALERT: $FILE accessed at $(date '+%H:%M:%S')"
    MSG="[INOTIFY] $FILE was accessed by unknown process on $(hostname) at $TIME"

    STATE_FILE="/tmp/inotify_last_$(basename "$FILE")"
    NOW=$(date +%s)
    LAST=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

    if (( NOW - LAST > 60 )); then
        echo "$NOW" > "$STATE_FILE"
        echo "$MSG" >> "$LOGFILE"
        echo "$MSG" | mail -s "$SUBJECT" "$EMAIL"
    fi
done
