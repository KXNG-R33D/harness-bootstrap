#!/usr/bin/env bash
# Stage 06 — n8n via Docker Compose (containerized, not npm global)
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[06-n8n] $*"; }

N8N_DATA_DIR="${N8N_DATA_DIR:-/home/${HOST_USER}/.local/share/n8n}"
N8N_COMPOSE="$BOOTSTRAP_DIR/configs/n8n/docker-compose.n8n.yml"

sudo -u "$HOST_USER" mkdir -p "$N8N_DATA_DIR"

export N8N_DATA_DIR N8N_PORT HOST_USER

if docker compose -f "$N8N_COMPOSE" ps 2>/dev/null | grep -q "running"; then
  log "n8n already running — skipping"
else
  log "Starting n8n container..."
  docker compose -f "$N8N_COMPOSE" up -d
  log "n8n started on port ${N8N_PORT:-5678}"
fi
