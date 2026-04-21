# Manual Steps

Things that cannot be fully automated — require operator action before or after install.

## Before Running install.sh

1. **Tailscale Auth Key**
   - Go to https://login.tailscale.com/admin/settings/keys
   - Generate a reusable auth key (check "Reusable" if provisioning multiple machines)
   - Paste into `.env` as `TAILSCALE_AUTH_KEY=tskey-auth-XXXXX`

2. **Copy `.env.example` → `.env`**
   - `cp .env.example .env && nano .env`

## After Running install.sh

3. **Refresh docker group membership** (no-sudo docker)
   - Log out and back in, or run: `newgrp docker`

4. **Verify Tailscale node in admin panel**
   - https://login.tailscale.com/admin/machines
   - Confirm `harness-host` appears and is connected
