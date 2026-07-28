# Verified implementation loop

This child branch carries executable overhaul slices. Its base branch contains the cross-platform verification workflow.

Rules:

1. Implement one coherent slice.
2. Add or update deterministic tests.
3. Wait for the Linux and Windows CI matrix.
4. Inspect failures and repair them before beginning another slice.
5. Update `PLAYABLE-STATE.md` with only observed results.
6. Keep approved character and ability names unchanged.
7. Keep in-match copy minimal and preserve semantic input/network contracts.

## Current gate

- Phase 1 data foundation is committed.
- Linux Node 20/22 tests pass.
- Windows Node 20/22 tests pass after documenting Node's forced process-termination exit status.
- Linux AppImage packaging smoke passes.
- Next slice: materialize the tested source snapshot and integrate the new roster into live simulation, UI, bots, and remote lobbies.
