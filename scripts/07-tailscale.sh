#!/usr/bin/env bash
# Stage 07 — Tailscale install + connect
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[07-tailscale] $*"; }

if ! command -v tailscale > /dev/null 2>&1; then
  log "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
else
  log "Tailscale already installed"
fi

systemctl enable tailscaled && systemctl start tailscaled

if tailscale status 2>/dev/null | grep -q "^[0-9]"; then
  log "Tailscale already connected"
else
  [[ -n "${TAILSCALE_AUTH_KEY:-}" ]] || { log "FAIL: TAILSCALE_AUTH_KEY not set"; exit 1; }
  tailscale up \
    --authkey="$TAILSCALE_AUTH_KEY" \
    --accept-routes \
    --ssh \
    --hostname="${TAILSCALE_HOSTNAME:-harness-host}"
  log "Tailscale connected"
fi

TS_IP=$(tailscale ip -4 2>/dev/null || echo "pending")
log "Tailscale node IP: $TS_IP"
