# FLUX decisions

- Existing history is preserved in the renamed `generalgroovy/flux` repository.
- `main` is protected from local-agent work; iterations use
  `agent/prototype-loop`.
- Aider uses the installed local Qwen 2.5 Coder 7B model in architect mode.
- Interactive and supervised agents share `.agent/agent.lock` so they cannot edit
  concurrently.
- Full-access mode applies only to the selected FLUX workspace and retains the
  repository's no-force-push, no-secrets, and evidence-based test requirements.
