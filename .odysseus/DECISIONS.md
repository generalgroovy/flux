# FLUX decisions

- Resolve checkout path, active branch, commit, and remote from live Git state;
  no machine-specific path or long-lived agent branch is assumed.
- `main`, `master`, `develop`, detached HEAD, and dirty trees are protected from
  local-agent work.
- Ollama serves either Qwen2.5-Coder 3B or 7B through Aider's
  `ollama_chat/` adapter with a bounded 16K context and 2K repository map.
- `auto` selects 7B with at least 16 GiB system RAM or 7 GiB detected VRAM and
  otherwise selects 3B.
- Aider is the supported lightweight code agent; Odysseus is an optional
  authenticated workspace using the same prompt, task, state, and shell gate.
- Interactive and bounded agents share `.agent/agent.lock` so they cannot edit
  concurrently.
- Interactive and bounded agents auto-approve local tool actions and create
  local commits after verification. `--no-commit` retains a bounded diff.
- Runtime accepts only loopback Ollama and disables telemetry, update checks,
  URL ingestion, dependency downloads, Git network protocols, and push.
- Every session writes a private XDG-state audit containing its manifest,
  terminal output, input/chat/LLM histories, final state, commits, and patches;
  agents may not suppress or delete this evidence.
