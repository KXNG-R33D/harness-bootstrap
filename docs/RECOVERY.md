# Recovery Procedures

## Ollama not responding
```bash
sudo systemctl restart ollama
curl http://localhost:11434/api/tags
```
If model is missing after restart:
```bash
ollama pull gemma4:31b
```

## hermes-watchdog not firing
```bash
sudo systemctl status hermes-watchdog
sudo journalctl -u hermes-watchdog -n 50
# Restart:
sudo systemctl restart hermes-watchdog
```

## n8n container down
```bash
docker ps -a | grep n8n
sudo systemctl restart n8n-harness
```

## openclaw container EACCES errors
Verify workspace dirs are owned by UID 1000:
```bash
ls -la ~/ai-agent-harness/openclaw-executor/workspace
ls -la ~/ai-agent-harness/openclaw-executor/evidence_drop
# Fix:
sudo chown -R ryan:ryan ~/ai-agent-harness/openclaw-executor/
```

## Re-run a single bootstrap stage
```bash
cd ~/harness-bootstrap
sudo bash install.sh --only=4   # re-pull Ollama model
sudo bash install.sh --only=11  # re-run verification
```
