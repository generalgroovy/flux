# Garuda Sway local-model handoff

## Stack

| Layer | Choice | Purpose |
| --- | --- | --- |
| Inference | Ollama | Local-only model API on `127.0.0.1:11434` |
| Model | Qwen2.5-Coder 3B or 7B | Code reading, editing, diagnosis, and test repair |
| Code agent | Aider | Git-aware repository map, edits, shell suggestions, and tests |
| Workspace | Odysseus (optional) | UI, sessions, scheduling, prompt/state handoff |
| Guardrail | `scripts/local-agent.sh` | Branch/tree checks, shared lock, bounded run, verification |

The repository does not install or vendor Odysseus. Its current upstream is a
self-hosted application with shell/file tools, so it should remain private and
authenticated. Aider is the supported lightweight code-development equivalent;
both use the same tracked prompt and state.

## Model choice

| Model | Ollama download | Practical starting point | Best FLUX work |
| --- | ---: | --- | --- |
| `qwen2.5-coder:3b` | about 1.9 GB | 8 GB system RAM | Docs, tests, narrow single-file fixes |
| `qwen2.5-coder:7b` | about 4.7 GB | 16 GB RAM or roughly 8 GB VRAM | Focused cross-file implementation |
| `auto` | one of the above | Selects 7B at >=16 GiB RAM or >=7 GiB VRAM | Default handoff |

Both profiles use 16K context to prevent silent short-context truncation while
keeping local memory use bounded. The repository map is limited to 2K tokens;
the model should inspect relevant files rather than ingest the whole codebase.

## First setup on Garuda

Review the installer, then run one of:

```bash
bash scripts/setup-local-agent-linux.sh --install --pull --model auto --backend cpu
bash scripts/setup-local-agent-linux.sh --install --pull --model 7b --backend cuda
bash scripts/setup-local-agent-linux.sh --install --pull --model 7b --backend rocm
```

`--install` is required before the script may invoke `pacman`, create its
user-local Aider virtual environment, or enable Ollama. Without `--install` or
`--pull`, the script is a read-only doctor. The managed Aider environment lives under
`${XDG_DATA_HOME:-$HOME/.local/share}/flux-local-agent`, outside the repository.

## Daily workflow

```bash
git switch -c agent/my-bounded-flux-task
bash scripts/local-agent.sh doctor --model auto
bash scripts/local-agent.sh chat --model auto
```

For one unattended but bounded pass:

```bash
bash scripts/local-agent.sh run --model 7b --iterations 1
```

That command edits and tests but intentionally leaves the result uncommitted.
After human review, either commit normally or explicitly allow a future run to
commit; pushing is a separate choice:

```bash
bash scripts/local-agent.sh run --model 7b --iterations 1 --commit
bash scripts/local-agent.sh run --model 7b --iterations 1 --push
```

Stop a running loop from another terminal with:

```bash
bash scripts/local-agent.sh stop
```

## Odysseus handoff

Install Odysseus separately from its official repository, keep authentication
enabled, do not publish the raw Ollama or Odysseus ports, and grant its agent
access only to the selected FLUX checkout. Use `.agent/ODYSSEUS_PROMPT.md` as
the preset/system prompt. The actual code task remains
`.agent/odysseus-task.md`; the agent should call one bounded repository run,
then return the diff and validation result for review.

Generate a live branch/commit/status handoff and place it on Sway's clipboard:

```bash
bash scripts/prepare-odysseus-handoff.sh --clipboard
```

Sway needs no special GUI integration. The bounded runner uses
`systemd-inhibit` when available and `notify-send` for completion/failure, while
remaining fully usable from a terminal without either feature.
