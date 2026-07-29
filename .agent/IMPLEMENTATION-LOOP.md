# Verified overhaul implementation loop

Run one complete slice on `integration/unify-flux` at a time.

1. Read the canonical documents in `.agent/OVERHAUL-PROMPT.md` order.
2. Confirm a clean non-protected branch and inspect recent history.
3. Select the first incomplete outcome in the active gate.
4. Define observable acceptance, unchanged boundaries, and non-goals.
5. Reuse only dependencies that pass the ground-up checks in
   `.agent/OVERHAUL-IMPLEMENTATION.md`.
6. Implement new product code under the overhaul boundary with an explicit
   compatibility adapter when necessary.
7. Add focused contract, deterministic, DOM, or visual tests.
8. Run focused tests, recursive syntax/build checks, the full suite, and
   `git diff --check`.
9. Render or launch the affected surface; record screenshots/behavior and any
   limitation without inventing acceptance.
10. Inspect the diff and remove copied helpers, generated junk, dead branches,
    stale terminology, and unrelated changes.
11. Update `.agent/memory.md`, `.agent/backlog.md`, and
    `.agent/PLAYABLE-STATE.md` with exact results and the next target.
12. Commit and push only a known-playable state, then wait for every Windows and
    Linux verification/package job before beginning the next production slice.

Mechanical work remains frozen until V0–V5 visual acceptance completes. A
source-only character specimen is visual evidence, not a live roster promotion.
