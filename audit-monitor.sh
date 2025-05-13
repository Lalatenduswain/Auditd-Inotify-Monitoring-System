#!/bin/bash

KEYWORDS=("passwd_watch" "shadow_watch")
EMAIL="lalatendu@ceruleaninfotech.com"
LOGFILE="/var/log/audit_email_alert.log"
HOSTNAME=$(hostname)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HTML_CONTENT=""
ALERT_COUNT=0

for KEY in "${KEYWORDS[@]}"; do
    EVENTS=$(ausearch -k "$KEY" -ts recent)
    [[ -z "$EVENTS" ]] && continue

    while read -r LINE; do
        FILE=$(echo "$LINE" | grep -oP 'name="[^"]+"' | head -n1 | cut -d= -f2 | tr -d '"')
        ACCESS_UID=$(echo "$LINE" | grep -oP 'uid=[0-9]+' | head -n1 | cut -d= -f2)
        USERNAME=$(getent passwd "$ACCESS_UID" | cut -d: -f1)
        [[ -z "$USERNAME" ]] && USERNAME="unknown"

        HTML_CONTENT+="
        <tr>
            <td>$KEY</td>
            <td>$FILE</td>
            <td>$USERNAME</td>
            <td>$ACCESS_UID</td>
            <td>$(date '+%Y-%m-%d %H:%M:%S')</td>
        </tr>"
        ALERT_COUNT=$((ALERT_COUNT + 1))
    done <<< "$EVENTS"
done

if (( ALERT_COUNT > 0 )); then
    EMAIL_BODY="
    <html>
    <head>
        <style>
            table {
                width: 100%;
                border-collapse: collapse;
                font-family: Arial, sans-serif;
            }
            th, td {
                border: 1px solid #ccc;
                padding: 8px;
                text-align: left;
            }
            th {
                background-color: #f5f5f5;
            }
        </style>
    </head>
    <body>
        <h3>Auditd Access Alert - $HOSTNAME</h3>
        <p><b>Timestamp:</b> $TIMESTAMP</p>
        <p>The following access events were detected:</p>
        <table>
            <tr>
                <th>Audit Key</th>
                <th>File</th>
                <th>User</th>
                <th>UID</th>
                <th>Time</th>
            </tr>
            $HTML_CONTENT
        </table>
        <p><i>Generated at $TIMESTAMP</i></p>
    </body>
    </html>"

    echo "$EMAIL_BODY" | mail -a "Content-Type: text/html" -s "AUDITD ALERT on $HOSTNAME at $TIMESTAMP" "$EMAIL"
    echo "[INFO] Sent $ALERT_COUNT audit alert(s) at $TIMESTAMP" >> "$LOGFILE"
fi
