# FLUX playable-state ledger

Date: 2026-07-28
Branch: `integration/unify-flux`
Base: `d77c0b2` (`agent/windows-linux-runtime`)

## Integrated state

The branch preserves the complete 0.34.3 live game and its Windows/Linux runtime
repair. It adds the independently tested future overhaul data foundation and one
canonical cross-platform verification workflow. The overhaul catalog remains
inactive: `src/content.mjs` and `src/match.mjs` are still authoritative for live
gameplay.

Integrated work:

- reliable Windows `npm.cmd` launch and authenticated graceful server cleanup;
- audited recovery tags for every pre-unification branch;
- reconciled overhaul constraints, system audit, compatibility matrix, and
  implementation loop;
- future eight-element, sixteen-race, sixteen-character, ability, reaction,
  movement, mode, and destruction data contracts;
- static character-balance profiling and roster diversity/counterplay guards;
- approved simple future display vocabulary and canonical character visual
  direction;
- one Windows/Ubuntu Node 20.19.1/22 verification matrix with real packaging
  jobs and failure diagnostics.

No checkpoint payload or checkpoint-generated source was applied. The manifest
cannot be reconstructed deterministically, as recorded in
`.agent/BRANCH-AUDIT.md`.

## Verified on current source

Observed on Windows on 2026-07-28:

- `npm.cmd ci` completed successfully earlier in the integration pass.
- `npm.cmd test` passed 109/109: 107 core/DOM/deterministic checks, one live
  WebSocket lifecycle, and one authenticated server-cleanup check.
- `node scripts/ci-verify.mjs` passed the same 109 tests and recursive syntax
  checks for all desktop, script, source, and test modules.
- PowerShell launcher parsing passed.
- The canonical workflow parsed as valid YAML.
- `npm.cmd audit --omit=dev` reported zero production vulnerabilities.
- A Windows NSIS package built successfully at commit `3a02958` before the
  inactive concept-data pass.

The full dependency audit reports 16 high-severity development-only findings in
the Electron packaging toolchain. Production dependencies remain clean; the dev
findings must be handled through dependency maintenance rather than concealed.

## Pending launch gate

The current source has not yet been rebuilt and exercised interactively after
the concept-data pass. Before publication as the durable `develop` branch:

1. rebuild the Windows package from current HEAD;
2. open the packaged application;
3. enter a real match through the Play flow;
4. close normally and verify all owned child processes exit;
5. push `develop` and wait for the Windows/Ubuntu CI and packaging jobs;
6. update this ledger with the resulting run URLs and artifacts.

Linux packaging and packaged launch require the GitHub Ubuntu job (or a Linux
host); neither is inferred from a Windows build. The unified branch must not be
merged to `main` until both platform gates are green and explicit final approval
is given.
