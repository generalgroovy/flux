# FLUX agent state

- Status: visual-first directive active; mechanics frozen until V0-V5 acceptance
- Branch: resolve with `git branch --show-current`; never assume a stored name
- Commit: resolve with `git rev-parse HEAD`; never assume a stored SHA
- Remote: resolve with `git remote -v`; never change it from an agent run
- Verification: run `npm test`; do not reuse a stored test count
- Playable state: read `.agent/PLAYABLE-STATE.md` and smoke affected behavior
- Task source: `.agent/VISUAL-OVERHAUL.md`, then `.agent/backlog.md`; V0 is accepted, Nico Lai is the first promoted V1 champion, and Steezo is the next bounded character slice
- Stop signal for a bounded local run: `.agent/STOP`

Use `bash scripts/linux-agent-handoff.sh doctor --model auto` before every
Odysseus or Aider handoff. Treat the current checkout as authoritative: the
last reviewed Windows baseline starts directly in the Living Sanctum as Nico
Lai, exposes all universal non-ability movement, and shows centralized champion
statistics. Re-run verification on Linux rather than trusting stored totals.
