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
- Sanctum-first DOM contract: `7ad6f0c034b86244a80138c782c7660ffd2f4e86`.
- DOM semantic-copy repair: `963f8e20998f519da5027872a94f068b2811699d`.
- First Rite launch contract: `bc7d6e4290b8ced322ed9bf5c199d57455c2e093`.
- Roster signature execution: `0e064c6ca8dbd100d4e04089713c16b470639e5c`.
- Every source patch passed compressed and decompressed SHA-256 verification before application.
- Local dependency-free verification passes 112 deterministic tests after the signature slice.
- All sixteen race champions retain catalog-specific tactical, defense, mobility, and ultimate execution; bots use the same four semantic action families.
- Cross-platform CI, WebSocket, DOM, desktop-security, and package verification are the active gate.
