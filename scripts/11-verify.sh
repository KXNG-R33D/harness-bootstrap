#!/usr/bin/env bash
# Stage 11 — End-to-end green/red verification table
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"

PASS="[  OK  ]"
FAIL="[ FAIL ]"
WARN="[ WARN ]"
results=()

chk() {
  local label="$1"; shift
  if "$@" > /dev/null 2>&1; then
    results+=("$PASS  $label")
  else
    results+=("$FAIL  $label")
  fi
}

warn_chk() {
  local label="$1"; shift
  if "$@" > /dev/null 2>&1; then
    results+=("$PASS  $label")
  else
    results+=("$WARN  $label")
  fi
}

HARNESS_DIR="/home/${HOST_USER}/ai-agent-harness"
VENV_PATH="/home/${HOST_USER}/.venv/harness"

chk      "Ubuntu 24.04 LTS"              bash -c '[[ "$(lsb_release -rs)" == "24.04" ]]'
warn_chk "NVIDIA GPU detected"           bash -c 'lspci | grep -qi nvidia'
chk      "Docker daemon running"         docker info
chk      "Docker Compose plugin"         docker compose version
warn_chk "nvidia-container-toolkit"      bash -c 'dpkg -l nvidia-container-toolkit | grep -q ^ii'
chk      "Python venv exists"            bash -c "[[ -d '$VENV_PATH' ]]"
chk      "Ollama binary present"         command -v ollama
chk      "Ollama service active"         systemctl is-active ollama
chk      "Ollama API responding"         curl -sf http://localhost:11434/api/tags
chk      "Ollama model loaded"           bash -c "ollama list | grep -q '${OLLAMA_MODEL:-gemma4:31b}'"
chk      "hermes-agent cloned"           bash -c "[[ -d '/home/${HOST_USER}/hermes-agent/.git' ]]"
chk      "Hermes .env present"           bash -c "[[ -f '/home/${HOST_USER}/.config/hermes/.env' ]]"
chk      "n8n container running"         bash -c 'docker ps | grep -q n8n'
chk      "Tailscale connected"           tailscale status
chk      "ai-agent-harness cloned"       bash -c "[[ -d '$HARNESS_DIR/.git' ]]"
chk      "openclaw .env present"         bash -c "[[ -f '$HARNESS_DIR/openclaw-executor/.env' ]]"
chk      "workspace/ dir exists"         bash -c "[[ -d '$HARNESS_DIR/openclaw-executor/workspace' ]]"
chk      "evidence_drop/ dir exists"     bash -c "[[ -d '$HARNESS_DIR/openclaw-executor/evidence_drop' ]]"
chk      "live-wiki/ dir exists"         bash -c "[[ -d '$HARNESS_DIR/knowledge-base/live-wiki' ]]"
chk      "hermes-watchdog active"        systemctl is-active hermes-watchdog
chk      "n8n-harness active"            systemctl is-active n8n-harness

echo ""
echo "============================================================"
echo "  HARNESS BOOTSTRAP — VERIFICATION REPORT"
echo "  $(date)"
echo "============================================================"
for r in "${results[@]}"; do echo "  $r"; done
echo "============================================================"

FAILS=$(printf '%s\n' "${results[@]}" | grep -c "FAIL" || true)
if [[ $FAILS -gt 0 ]]; then
  echo "  $FAILS check(s) FAILED — review above before proceeding"
  exit 1
else
  echo "  ALL CHECKS PASSED"
  echo ""
  echo "  NEXT: cd ~/ai-agent-harness && docker compose up -d"
fi
