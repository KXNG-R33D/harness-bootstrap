#!/usr/bin/env bash
# Stage 02 — Docker Engine + Compose plugin + NVIDIA Container Toolkit
set -euo pipefail
BOOTSTRAP_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..") && pwd)}"
source "$BOOTSTRAP_DIR/.env"
log() { echo "[02-docker] $*"; }

if docker info > /dev/null 2>&1; then
  log "Docker already running — skipping install"
else
  log "Adding Docker apt repo..."
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
  log "Docker installed"
fi

usermod -aG docker "$HOST_USER" && log "Added $HOST_USER to docker group"

if nvidia-smi > /dev/null 2>&1; then
  if ! dpkg -l nvidia-container-toolkit > /dev/null 2>&1; then
    log "Installing NVIDIA Container Toolkit..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
      gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
      > /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update -qq
    apt-get install -y -qq nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
    log "NVIDIA Container Toolkit installed"
  else
    log "NVIDIA Container Toolkit already present"
  fi
else
  log "WARN: nvidia-smi not found — skipping toolkit. CPU inference only."
fi

systemctl enable docker && systemctl start docker
log "Docker service enabled and started"
