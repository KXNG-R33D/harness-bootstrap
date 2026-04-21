# harness-bootstrap

> **Single-command host provisioner for [ai-agent-harness](https://github.com/KXNG-R33D/ai-agent-harness)**
> Clone this repo on a fresh Ubuntu 24.04.4 LTS machine, fill in one `.env` file, run one command. Done.

---

## What This Does

Provisions a bare Ubuntu 24.04.4 LTS host from first boot to fully operational AI agent harness by installing and configuring:

| Software | Purpose | Method |
|---|---|---|
| Docker Engine + Compose | Runs openclaw-executor container | apt (official repo) |
| NVIDIA Container Toolkit | GPU passthrough to Docker | apt (nvidia repo) |
| Python 3.12 + venv | Host-side Hermes governance | system + venv |
| Ollama + `gemma4:31b` | Local LLM inference | official installer |
| NousResearch/hermes-agent | Governance plane agent | git clone + setup-hermes.sh |
| n8n | Workflow automation UI | Docker Compose |
| Tailscale | Secure remote access + SSH | official installer |
| ai-agent-harness | The agent execution system | git clone + .env inject |

---

## Usage

### Step 1 — Clone this repo
```bash
git clone https://github.com/KXNG-R33D/harness-bootstrap.git
cd harness-bootstrap
```

### Step 2 — Fill in your .env (the ONLY manual step)
```bash
cp .env.example .env
nano .env
```
Required fields:
- `TAILSCALE_AUTH_KEY` — from https://login.tailscale.com/admin/settings/keys
- `HOST_USER` — your Linux username (default: `ryan`)
- `OLLAMA_MODEL` — default `gemma4:31b` (do not change unless intentional)

### Step 3 — Run the installer
```bash
sudo bash install.sh
```

Installation takes **20-40 minutes** on first run — most of the time is `ollama pull gemma4:31b` (the 31B model is large).

### Step 4 — Start the harness
```bash
cd ~/ai-agent-harness
docker compose up -d
make state
```

---

## Resume / Partial Install

```bash
sudo bash install.sh --from=5    # resume from stage 5 (e.g., after network drop during model pull)
sudo bash install.sh --only=11   # run verification only
sudo bash install.sh --verify    # alias for --only=11
```

---

## Stage Map

| Stage | Script | What It Does |
|---|---|---|
| 00 | `00-preflight.sh` | Validates Ubuntu version, GPU, internet, .env completeness |
| 01 | `01-system-packages.sh` | apt update/upgrade + baseline tools |
| 02 | `02-docker.sh` | Docker Engine, Compose plugin, NVIDIA Container Toolkit |
| 03 | `03-python.sh` | Python venv at `~/.venv/harness`, harness pip deps |
| 04 | `04-ollama.sh` | Ollama install, systemd override, `gemma4:31b` pull |
| 05 | `05-hermes.sh` | Clone NousResearch/hermes-agent, run setup-hermes.sh |
| 06 | `06-n8n.sh` | n8n Docker Compose stack, port 5678 |
| 07 | `07-tailscale.sh` | Tailscale install + `tailscale up --ssh` |
| 08 | `08-clone-harness.sh` | Clone ai-agent-harness, inject openclaw .env |
| 09 | `09-directory-skeleton.sh` | All required dirs with UID 1000 ownership |
| 10 | `10-systemd-services.sh` | n8n-harness.service + hermes-watchdog.service |
| 11 | `11-verify.sh` | Full green/red verification table |

---

## After First Boot (Autonomous Operation)

After `sudo reboot`, these services start automatically in order:
1. `ollama.service` — Ollama LLM runtime
2. `docker.service` — Docker daemon
3. `n8n-harness.service` — n8n workflow UI (after docker)
4. `hermes-watchdog.service` — watches `evidence_drop/`, fires `make review` on new files (after ollama)

The operator's only ongoing action is dropping tasks to `workspace/task_queue.json`.

---

## Service Ports

| Service | Port | Access |
|---|---|---|
| n8n UI | 5678 | http://localhost:5678 or via Tailscale IP |
| Ollama API | 11434 | http://localhost:11434 (host only) |
| Tailscale SSH | 22 | via `ssh ryan@<tailscale-ip>` |

---

## Idempotency

Every script checks whether its work is already done before re-doing it. Re-running `install.sh` on a provisioned host is safe and will only apply missing pieces.

---

## Related Repos

- [KXNG-R33D/ai-agent-harness](https://github.com/KXNG-R33D/ai-agent-harness) — the agent system this bootstraps
- [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) — governance plane agent
