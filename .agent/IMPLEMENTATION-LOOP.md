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

- Integrated overhaul checkpoint: `75a09410db21027e45478591541a949473da7f13`.
- DOM compatibility repair: `4aa8e2e74b0dcf36790f3cb3cc31b25bd1b878d7`.
- Both patches passed compressed and decompressed SHA-256 verification before application.
- Local dependency-free verification passes 104 integrated simulation/content/lobby tests after the repair.
- The previous CI failure was a read-only Linkedom `<select>.value`; production now selects options through a browser-compatible fallback.
- Cross-platform CI, WebSocket, desktop-security, and package verification remain the active gate.
