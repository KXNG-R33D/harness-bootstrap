#!/usr/bin/env bash
# Stage 08 — Clone ai-agent-harness + inject .env
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[08-clone-harness] $*"; }

HARNESS_DIR="/home/${HOST_USER}/ai-agent-harness"
HARNESS_REPO="https://github.com/KXNG-R33D/ai-agent-harness"

if [[ -d "$HARNESS_DIR/.git" ]]; then
  log "ai-agent-harness already cloned — pulling latest"
  sudo -u "$HOST_USER" git -C "$HARNESS_DIR" pull --ff-only
else
  log "Cloning ai-agent-harness to $HARNESS_DIR ..."
  sudo -u "$HOST_USER" git clone "$HARNESS_REPO" "$HARNESS_DIR"
fi

HARNESS_ENV="$HARNESS_DIR/openclaw-executor/.env"
if [[ ! -f "$HARNESS_ENV" ]]; then
  log "Writing openclaw-executor/.env from bootstrap template..."
  sudo -u "$HOST_USER" cp "$BOOTSTRAP_DIR/skeleton/env-template.txt" "$HARNESS_ENV"
  sed -i "s|OLLAMA_BASE_URL=.*|OLLAMA_BASE_URL=http://172.17.0.1:11434|" "$HARNESS_ENV"
  sed -i "s|OLLAMA_DEFAULT_MODEL=.*|OLLAMA_DEFAULT_MODEL=${OLLAMA_MODEL:-gemma4:31b}|" "$HARNESS_ENV"
  log "openclaw-executor/.env written"
else
  log "openclaw-executor/.env already exists — not overwriting"
fi

log "ai-agent-harness ready at $HARNESS_DIR"
