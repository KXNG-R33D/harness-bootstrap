#!/usr/bin/env bash
# Stage 03 — Python 3.12 + shared venv at ~/.venv/harness
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[03-python] $*"; }

VENV_PATH="/home/${HOST_USER}/.venv/harness"

PY_VER=$(python3 --version 2>&1 | awk '{print $2}')
log "Python version: $PY_VER"

if [[ ! -d "$VENV_PATH" ]]; then
  log "Creating shared venv at $VENV_PATH"
  sudo -u "$HOST_USER" python3 -m venv "$VENV_PATH"
fi

log "Upgrading pip..."
sudo -u "$HOST_USER" "$VENV_PATH/bin/pip" install --upgrade pip wheel setuptools -q

log "Installing harness Python dependencies..."
sudo -u "$HOST_USER" "$VENV_PATH/bin/pip" install \
  "httpx>=0.27,<0.28" \
  "pydantic>=2.7,<3.0" \
  "rich>=13.7,<14.0" \
  "python-dotenv>=1.0,<2.0" \
  "structlog>=24.1,<25.0" \
  "tenacity>=8.3,<9.0" \
  "python-dateutil>=2.9,<3.0" \
  "psutil>=5.9,<7.0" \
  -q

log "Venv ready: $VENV_PATH"
