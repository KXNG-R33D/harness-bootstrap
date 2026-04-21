#!/usr/bin/env bash
# Manual Tailscale connect helper (called by 07-tailscale.sh)
source "$(dirname "$0")/../../.env"
tailscale up \
  --authkey="$TAILSCALE_AUTH_KEY" \
  --accept-routes \
  --ssh \
  --hostname="${TAILSCALE_HOSTNAME:-harness-host}"
