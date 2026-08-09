# FLUX verification contract

Run targeted tests during implementation, followed by:

```bash
npm test
bash -n scripts/*.sh
git diff --check
```

For launcher/server changes also run `bash scripts/test-changes.sh` or an
equivalent live `/__flux_health` smoke. PowerShell behavior must be recorded as
unverified when no Windows/PowerShell environment was actually used.

For local-agent handoff changes also run:

```bash
node --test tests/local-agent-handoff.test.mjs
bash scripts/linux-agent-handoff.sh --help
bash scripts/local-agent.sh --help
bash scripts/setup-local-agent-linux.sh --help
bash scripts/prepare-odysseus-handoff.sh --help
bash scripts/local-agent.sh logs
```

Run `bash scripts/setup-local-agent-linux.sh --check` on the actual Garuda host;
another operating system cannot prove its packages, Ollama service, GPU backend,
model inventory, or Sway notifications.

After one real target session, inspect every file named in
`.agent/LOCAL-MODEL-HANDOFF.md`; require the manifest, event timeline,
transcripts, final state, commits, and patches to agree with the visible run.
