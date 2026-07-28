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
- The checkpoint patch passed compressed and decompressed SHA-256 verification before application.
- Local dependency-free verification passed 112 deterministic tests before publication.
- Cross-platform CI, DOM, WebSocket, desktop-security, and package verification are the active gate.
- No subsequent gameplay slice begins until that gate passes or its failures are repaired.
