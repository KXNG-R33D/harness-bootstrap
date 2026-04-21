#!/usr/bin/env bash
# Stage 04 — Ollama install + systemd override + model pull
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[04-ollama] $*"; }

if ! command -v ollama > /dev/null 2>&1; then
  log "Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
else
  log "Ollama already installed — skipping"
fi

OVERRIDE_DIR="/etc/systemd/system/ollama.service.d"
mkdir -p "$OVERRIDE_DIR"
cp "$BOOTSTRAP_DIR/configs/ollama/ollama-override.conf" "$OVERRIDE_DIR/override.conf"
log "Ollama systemd override applied (OLLAMA_HOST=0.0.0.0:11434)"

systemctl daemon-reload
systemctl enable ollama
systemctl restart ollama
log "Ollama service started"

log "Waiting for Ollama API..."
for i in {1..30}; do
  curl -s http://localhost:11434/api/tags > /dev/null 2>&1 && break
  sleep 2
done
curl -s http://localhost:11434/api/tags > /dev/null 2>&1 || { log "FAIL: Ollama not responding"; exit 1; }
log "Ollama API reachable"

MODEL="${OLLAMA_MODEL:-gemma4:31b}"
if ollama list 2>/dev/null | grep -q "$MODEL"; then
  log "Model $MODEL already present"
else
  log "Pulling model $MODEL — this may take 15-30 minutes on first run..."
  ollama pull "$MODEL"
  log "Model $MODEL ready"
fi
