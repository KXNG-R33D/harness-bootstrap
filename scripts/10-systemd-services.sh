#!/usr/bin/env bash
# Stage 10 — Register n8n-harness.service and hermes-watchdog.service
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[10-systemd-services] $*"; }

HARNESS_DIR="/home/${HOST_USER}/ai-agent-harness"
N8N_COMPOSE="$BOOTSTRAP_DIR/configs/n8n/docker-compose.n8n.yml"
N8N_DATA_DIR="${N8N_DATA_DIR:-/home/${HOST_USER}/.local/share/n8n}"

cat > /etc/systemd/system/n8n-harness.service << EOF
[Unit]
Description=n8n Workflow Automation (harness)
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=root
Environment=N8N_DATA_DIR=${N8N_DATA_DIR}
Environment=N8N_PORT=${N8N_PORT:-5678}
Environment=HOST_USER=${HOST_USER}
ExecStart=/usr/bin/docker compose -f ${N8N_COMPOSE} up -d
ExecStop=/usr/bin/docker compose -f ${N8N_COMPOSE} down

[Install]
WantedBy=multi-user.target
EOF
log "n8n-harness.service written"

cat > /etc/systemd/system/hermes-watchdog.service << EOF
[Unit]
Description=Hermes Review Gate Watchdog
After=ollama.service network-online.target
Wants=ollama.service

[Service]
Type=simple
User=${HOST_USER}
WorkingDirectory=${HARNESS_DIR}
EnvironmentFile=/home/${HOST_USER}/.config/hermes/.env
ExecStart=${BOOTSTRAP_DIR}/scripts/hermes-watchdog.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
log "hermes-watchdog.service written"

cat > "$BOOTSTRAP_DIR/scripts/hermes-watchdog.sh" << 'WATCHDOG'
#!/usr/bin/env bash
# Watches evidence_drop/ and fires 'make review' on new files
HARNESS_DIR="/home/PLACEHOLDER_USER/ai-agent-harness"
log() { echo "[hermes-watchdog] $(date '+%Y-%m-%dT%H:%M:%S') $*"; }
log "Watchdog started — monitoring $HARNESS_DIR/openclaw-executor/evidence_drop/"
while true; do
  inotifywait -e close_write,moved_to \
    "$HARNESS_DIR/openclaw-executor/evidence_drop/" 2>/dev/null && \
    { log "New evidence detected — triggering make review"; cd "$HARNESS_DIR" && make review; }
done
WATCHDOG

sed -i "s|PLACEHOLDER_USER|${HOST_USER}|" "$BOOTSTRAP_DIR/scripts/hermes-watchdog.sh"
chmod +x "$BOOTSTRAP_DIR/scripts/hermes-watchdog.sh"
log "hermes-watchdog.sh written"

systemctl daemon-reload
systemctl enable n8n-harness.service hermes-watchdog.service
systemctl start n8n-harness.service || log "WARN: n8n start failed — check docker"
systemctl start hermes-watchdog.service || log "WARN: hermes-watchdog start failed"
log "All systemd services registered"
