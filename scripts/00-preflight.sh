#!/usr/bin/env bash
# Stage 00 — Preflight: validate host before touching anything
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"

log() { echo "[00-preflight] $*"; }
die() { log "FAIL: $*"; exit 1; }
pass() { log "OK: $*"; }

DISTRO=$(lsb_release -is 2>/dev/null || echo "Unknown")
VERSION=$(lsb_release -rs 2>/dev/null || echo "0")
[[ "$DISTRO" == "Ubuntu" ]] || die "Not Ubuntu (got $DISTRO). Requires Ubuntu 24.04."
[[ "$VERSION" == "24.04" ]] || die "Ubuntu version $VERSION detected. Requires 24.04."
pass "Ubuntu 24.04 LTS confirmed"

if lspci 2>/dev/null | grep -qi nvidia; then
  pass "NVIDIA GPU detected"
else
  log "WARN: No NVIDIA GPU detected. Ollama will run on CPU."
fi

for host in github.com ollama.com download.docker.com; do
  curl -s --max-time 5 "https://$host" > /dev/null 2>&1 && pass "Reachable: $host" || die "Cannot reach $host"
done

for key in TAILSCALE_AUTH_KEY HOST_USER OLLAMA_MODEL; do
  val="${!key:-}"
  [[ -n "$val" ]] && pass ".env key present: $key" || die ".env missing required key: $key"
done

pass "Preflight complete"
