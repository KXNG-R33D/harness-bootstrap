#!/usr/bin/env bash
# Stage 05 — Clone NousResearch/hermes-agent + install via setup-hermes.sh
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[05-hermes] $*"; }

HERMES_REPO="https://github.com/NousResearch/hermes-agent"
HERMES_DIR="/home/${HOST_USER}/hermes-agent"
VENV_PATH="/home/${HOST_USER}/.venv/harness"

if [[ -d "$HERMES_DIR/.git" ]]; then
  log "hermes-agent already cloned — pulling latest"
  sudo -u "$HOST_USER" git -C "$HERMES_DIR" pull --ff-only
else
  log "Cloning hermes-agent to $HERMES_DIR ..."
  sudo -u "$HOST_USER" git clone --recurse-submodules "$HERMES_REPO" "$HERMES_DIR"
fi

if [[ -f "$HERMES_DIR/setup-hermes.sh" ]]; then
  log "Running hermes setup-hermes.sh..."
  cd "$HERMES_DIR"
  sudo -u "$HOST_USER" bash setup-hermes.sh 2>&1 | tail -20
else
  log "setup-hermes.sh not found — falling back to pip install"
  sudo -u "$HOST_USER" "$VENV_PATH/bin/pip" install -e "$HERMES_DIR" -q
fi

HERMES_CONF_DIR="/home/${HOST_USER}/.config/hermes"
sudo -u "$HOST_USER" mkdir -p "$HERMES_CONF_DIR"

if [[ ! -f "$HERMES_CONF_DIR/.env" ]]; then
  log "Writing Hermes .env config..."
  sudo -u "$HOST_USER" cp "$BOOTSTRAP_DIR/configs/hermes/hermes.env.example" "$HERMES_CONF_DIR/.env"
  sed -i "s|OLLAMA_BASE_URL=.*|OLLAMA_BASE_URL=http://172.17.0.1:11434|" "$HERMES_CONF_DIR/.env"
  sed -i "s|OLLAMA_DEFAULT_MODEL=.*|OLLAMA_DEFAULT_MODEL=${OLLAMA_MODEL:-gemma4:31b}|" "$HERMES_CONF_DIR/.env"
  log "Hermes .env written"
else
  log "Hermes .env already present — not overwriting"
fi

log "hermes-agent installed at $HERMES_DIR"
