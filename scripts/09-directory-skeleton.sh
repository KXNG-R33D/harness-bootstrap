#!/usr/bin/env bash
# Stage 09 — Create all required dirs with UID 1000 ownership
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[09-directory-skeleton] $*"; }

HARNESS_DIR="/home/${HOST_USER}/ai-agent-harness"
HOME_DIR="/home/${HOST_USER}"
DIRS_MANIFEST="$BOOTSTRAP_DIR/skeleton/harness-dirs.txt"

while IFS= read -r dir_template; do
  [[ "$dir_template" =~ ^#.*$ || -z "$dir_template" ]] && continue
  dir="${dir_template/\$HARNESS_DIR/$HARNESS_DIR}"
  dir="${dir/\$HOME/$HOME_DIR}"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    log "Created: $dir"
  else
    log "Exists:  $dir"
  fi
  chown -R "${HOST_USER}:${HOST_USER}" "$dir"
done < "$DIRS_MANIFEST"

log "Directory skeleton complete — all dirs owned by ${HOST_USER}:${HOST_USER}"
