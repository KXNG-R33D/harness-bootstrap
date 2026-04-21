# harness-bootstrap — Status

_Auto-updated by Space instructions. Track all config changes and repo events here._

## Current State

| Item | Status | Notes |
|---|---|---|
| Repo created | ✅ 2026-04-21 | https://github.com/KXNG-R33D/harness-bootstrap |
| install.sh | ✅ committed | 12-stage idempotent bootstrap |
| Stage scripts 00-11 | ✅ committed | Full pipeline from preflight to verify |
| configs/ollama | ✅ committed | systemd override, 0.0.0.0:11434 |
| configs/hermes | ✅ committed | hermes.env.example |
| configs/n8n | ✅ committed | docker-compose.n8n.yml |
| configs/tailscale | ✅ committed | tailscale-up.sh |
| skeleton/ | ✅ committed | harness-dirs.txt + env-template.txt |
| docs/ | ✅ committed | MANUAL-STEPS.md + RECOVERY.md |
| .env.example | ✅ committed | TAILSCALE_AUTH_KEY, HOST_USER, OLLAMA_MODEL |
| .gitignore | ✅ committed | .env excluded |

## Changelog

### 2026-04-21 — Initial bootstrap repo created
- Repo: KXNG-R33D/harness-bootstrap
- HOST_USER=ryan
- Hermes Agent: NousResearch/hermes-agent (installed at ~/hermes-agent)
- Harness: KXNG-R33D/ai-agent-harness (installed at ~/ai-agent-harness)
- Services registered: ollama.service, n8n-harness.service, hermes-watchdog.service
- Ollama model default: gemma4:31b
- n8n port: 5678
- Tailscale: SSH enabled, hostname harness-host
