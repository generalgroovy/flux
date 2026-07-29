# FLUX agent state

- Status: visual-first directive active; mechanics frozen until V0-V5 acceptance
- Branch: resolve with `git branch --show-current`; never assume a stored name
- Commit: resolve with `git rev-parse HEAD`; never assume a stored SHA
- Remote: resolve with `git remote -v`; never change it from an agent run
- Verification: run `npm test`; do not reuse a stored test count
- Playable state: read `.agent/PLAYABLE-STATE.md` and smoke affected behavior
- Task source: `.agent/VISUAL-OVERHAUL.md`, then `.agent/backlog.md`; begin at V0
- Stop signal for a bounded local run: `.agent/STOP`

Use `bash scripts/local-agent.sh doctor` before every Odysseus or Aider handoff.
