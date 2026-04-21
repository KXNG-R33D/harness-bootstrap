#!/usr/bin/env bash
# Stage 01 — System packages baseline
set -euo pipefail
log() { echo "[01-system-packages] $*"; }

log "Updating apt..."
apt-get update -qq
apt-get upgrade -y -qq

PKGS=(
  git curl wget make build-essential ca-certificates gnupg
  lsb-release python3 python3-pip python3-venv python3-dev
  htop nvtop unzip jq software-properties-common apt-transport-https
  inotify-tools net-tools
)

log "Installing: ${PKGS[*]}"
apt-get install -y -qq "${PKGS[@]}"
log "System packages installed"
