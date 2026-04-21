#!/usr/bin/env bash
# ==============================================================================
# harness-bootstrap — install.sh
# Single entry point. Run: sudo bash install.sh
# Flags:
#   --from=N    Resume from stage N (0-11)
#   --only=N    Run only stage N
#   --verify    Run stage 11 (verify) only
# ==============================================================================
set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/harness-bootstrap.log"
START_FROM=0
ONLY_STAGE=""

for arg in "$@"; do
  case $arg in
    --from=*) START_FROM="${arg#*=}" ;;
    --only=*) ONLY_STAGE="${arg#*=}" ;;
    --verify) ONLY_STAGE=11 ;;
  esac
done

log() { echo "[$(date '+%Y-%m-%dT%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
die() { log "FATAL: $*"; exit 1; }

[[ $EUID -eq 0 ]] || die "Must run as root: sudo bash install.sh"
[[ -f "$BOOTSTRAP_DIR/.env" ]] || die ".env not found. Copy .env.example -> .env and fill in values."

set -a; source "$BOOTSTRAP_DIR/.env"; set +a

log "====== harness-bootstrap START ($(date)) ======"

STAGES=(
  "00-preflight"
  "01-system-packages"
  "02-docker"
  "03-python"
  "04-ollama"
  "05-hermes"
  "06-n8n"
  "07-tailscale"
  "08-clone-harness"
  "09-directory-skeleton"
  "10-systemd-services"
  "11-verify"
)

run_stage() {
  local idx=$1
  local name="${STAGES[$idx]}"
  local script="$BOOTSTRAP_DIR/scripts/${name}.sh"
  [[ -f "$script" ]] || die "Stage script not found: $script"
  log "--- Stage $idx: $name ---"
  bash "$script" "$BOOTSTRAP_DIR" 2>&1 | tee -a "$LOG_FILE"
  log "--- Stage $idx: $name COMPLETE ---"
}

if [[ -n "$ONLY_STAGE" ]]; then
  run_stage "$ONLY_STAGE"
else
  for i in "${!STAGES[@]}"; do
    [[ $i -ge $START_FROM ]] && run_stage "$i"
  done
fi

log "====== harness-bootstrap COMPLETE ======"
log "Next: cd ~/ai-agent-harness && docker compose up -d"
